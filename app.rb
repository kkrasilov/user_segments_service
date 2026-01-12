require 'roda'
require 'json'
require_relative 'config/database'
require_relative 'models/user'
require_relative 'models/segment'
require_relative 'models/user_segment'

class App < Roda
  plugin :render
  plugin :json
  plugin :halt
  plugin :json_parser
  plugin :public

  route do |r|
    r.root do
      view(:index)
    end

    # API Routes
    r.on 'api' do
      # Segments API
      r.on 'segments' do
        r.is String do |slug|
          segment = Segment.find_by(slug: slug)
          
          unless segment
            response.status = 404
            next { error: 'Segment not found' }
          end

          # Update segment
          if r.put?
            data = r.params
            auto_assign_percent = data['auto_assign_percent']&.to_i
            
            # Validate auto_assign_percent
            if auto_assign_percent && (auto_assign_percent < 0 || auto_assign_percent > 100)
              response.status = 400
              next { error: 'auto_assign_percent must be between 0 and 100' }
            end
            
            update_data = {}
            update_data[:name] = data['name'] if data['name']
            update_data[:description] = data['description'] if data.key?('description')
            
            begin
              segment.update!(update_data) unless update_data.empty?
              
              # Redistribute segment to match target percentage
              if auto_assign_percent && auto_assign_percent >= 0
                total_users = User.count
                
                if total_users > 0
                  # Remove all current assignments
                  segment.user_segments.destroy_all
                  
                  # Assign to new random percentage of users
                  if auto_assign_percent > 0
                    target_count = (total_users * auto_assign_percent / 100.0).round
                    
                    # Select random users
                    selected_users = User.order("RANDOM()").limit(target_count)
                    
                    selected_users.each do |user|
                      UserSegment.create(user: user, segment: segment)
                    end
                  end
                end
              end
              
              {
                id: segment.id,
                slug: segment.slug,
                name: segment.name,
                description: segment.description,
                updated_at: segment.updated_at
              }
            rescue ActiveRecord::RecordInvalid => e
              response.status = 422
              { error: e.message }
            end
          # Delete segment
          elsif r.delete?
            segment.destroy
            
            response.status = 204
            {}
          end
        end

        # Create segment (at root level)
        r.post do
          data = r.params
          
          slug = data['slug']
          name = data['name']
          description = data['description']
          auto_assign_percent = data['auto_assign_percent']&.to_i

          # Validation
          if slug.nil? || slug.empty?
            response.status = 400
            next { error: 'Slug is required' }
          end

          if auto_assign_percent && (auto_assign_percent < 0 || auto_assign_percent > 100)
            response.status = 400
            next { error: 'auto_assign_percent must be between 0 and 100' }
          end

          # Check slug uniqueness
          if Segment.exists?(slug: slug)
            response.status = 409
            next { error: 'Segment with this slug already exists' }
          end

          begin
            segment = Segment.create!(
              slug: slug,
              name: name || slug,
              description: description
            )

            # Auto-assign segment to random users
            if auto_assign_percent && auto_assign_percent > 0
              segment.assign_to_random_users(auto_assign_percent)
            end

            response.status = 201
            {
              id: segment.id,
              slug: segment.slug,
              name: segment.name,
              description: segment.description,
              created_at: segment.created_at
            }
          rescue ActiveRecord::RecordInvalid => e
            response.status = 422
            { error: e.message }
          end
        end
      end

      # Users API
      r.on 'users' do
        # Get stats
        r.is 'stats' do
          r.get do
            {
              total_users: User.count
            }
          end
        end

        # Create user
        r.post do
          begin
            user = User.create!
            
            response.status = 201
            {
              id: user.id,
              created_at: user.created_at
            }
          rescue ActiveRecord::RecordInvalid => e
            response.status = 422
            { error: e.message }
          end
        end

        # User-specific routes
        r.on Integer do |user_id|
          user = User.find_by(id: user_id)
          
          unless user
            response.status = 404
            next { error: 'User not found' }
          end

          r.on 'segments' do
            # Get user segments
            r.get do
              segments = user.segments
              
              {
                user_id: user.id,
                segments: segments.map { |s| 
                  {
                    slug: s.slug,
                    name: s.name,
                    description: s.description
                  }
                }
              }
            end

            # Add segments to user
            r.post do
              data = r.params
              segment_slugs = data['segments'] || []

              if segment_slugs.empty?
                response.status = 400
                next { error: 'No segments provided' }
              end

              added_segments = []
              errors = []

              segment_slugs.each do |slug|
                segment = Segment.find_by(slug: slug)
                
                unless segment
                  errors << "Segment '#{slug}' not found"
                  next
                end

                # Check if already assigned
                if user.segments.include?(segment)
                  errors << "User already has segment '#{slug}'"
                else
                  begin
                    UserSegment.create!(user: user, segment: segment)
                    added_segments << slug
                  rescue ActiveRecord::RecordInvalid => e
                    errors << "Failed to add segment '#{slug}': #{e.message}"
                  end
                end
              end

              {
                added: added_segments,
                errors: errors
              }
            end

            # Remove segments from user
            r.delete do
              data = r.params
              segment_slugs = data['segments'] || []

              if segment_slugs.empty?
                response.status = 400
                next { error: 'No segments provided' }
              end

              removed_segments = []
              errors = []

              segment_slugs.each do |slug|
                segment = Segment.find_by(slug: slug)
                
                unless segment
                  errors << "Segment '#{slug}' not found"
                  next
                end

                user_segment = UserSegment.find_by(user: user, segment: segment)
                
                if user_segment
                  user_segment.destroy
                  removed_segments << slug
                else
                  errors << "User doesn't have segment '#{slug}'"
                end
              end

              {
                removed: removed_segments,
                errors: errors
              }
            end
          end
        end
      end
    end

    # Web UI Routes
    r.on 'segments' do
      r.is do
        r.get do
          @segments = Segment.order(:slug).all
          view(:segments)
        end
      end

      r.on 'new' do
        r.get do
          view(:segment_form)
        end
      end
    end

    r.on 'users' do
      r.is do
        r.get do
          @users = User.order(:id).limit(100).all
          view(:users)
        end
      end
    end
  end
end

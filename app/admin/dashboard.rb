ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    style do
      raw <<-CSS
        .dashboard-wrapper {
          background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><path fill="rgba(0, 0, 0, 0.05)" d="M11 38L34 14L56 38L34 62Z"/></svg>') repeat, #f3f4f6;
          min-height: 100vh;
          padding: 2rem;
        }
        .dashboard-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          background: #ffffff;
          border-radius: 0.75rem;
          padding: 1.5rem;
          margin-bottom: 2rem;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .dashboard-header h1 {
          font-size: 1.75rem;
          font-weight: 700;
          color: #1f2937;
        }
        .dashboard-search {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          background: #f1f5f9;
          border-radius: 0.5rem;
          padding: 0.5rem 1rem;
        }
        .dashboard-search input {
          background: transparent;
          border: none;
          outline: none;
          color: #4b5563;
        }
        .dashboard-container {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
          gap: 1.5rem;
        }
        .dashboard-panel {
          background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
          border-radius: 0.75rem;
          box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
          padding: 1.75rem;
          transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .dashboard-panel:hover {
          transform: scale(1.02);
          box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
        }
        .panel-title {
          font-size: 1.375rem;
          font-weight: 600;
          color: #111827;
          margin-bottom: 1.25rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
        }
        .panel-title svg {
          width: 24px;
          height: 24px;
          fill: #2563eb;
        }
        .panel-content {
          color: #4b5563;
          font-size: 0.95rem;
        }
        .panel-content ul {
          list-style: none;
          padding: 0;
        }
        .panel-content li {
          padding: 0.75rem 0;
          border-bottom: 1px solid #e5e7eb;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          transition: background 0.2s;
        }
        .panel-content li:hover {
          background: #f1f5f9;
        }
        .panel-content li:last-child {
          border-bottom: none;
        }
        .panel-content a {
          color: #2563eb;
          text-decoration: none;
          font-weight: 500;
        }
        .panel-content a:hover {
          color: #1d4ed8;
        }
        .metric {
          font-size: 1.75rem;
          font-weight: 700;
          color: #111827;
        }
        .metric-label {
          font-size: 0.9rem;
          color: #6b7280;
        }
        .welcome-message {
          text-align: center;
          padding: 3rem;
          background: linear-gradient(135deg, #6366f1 0%, #3b82f6 100%);
          color: #ffffff;
          border-radius: 0.75rem;
          margin-bottom: 2rem;
          position: relative;
          overflow: hidden;
        }
        .welcome-message::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
          opacity: 0.5;
        }
        .welcome-message h1 {
          font-size: 2.25rem;
          font-weight: 800;
          margin-bottom: 0.75rem;
          position: relative;
        }
        .welcome-message p {
          font-size: 1.125rem;
          position: relative;
        }
        .thumbnail {
          width: 60px;
          height: 90px;
          object-fit: cover;
          border-radius: 0.375rem;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
      CSS
    end

    div class: "dashboard-header" do
      h1 I18n.t("active_admin.dashboard_welcome.welcome")
      div class: "dashboard-search" do
        raw <<-SVG
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5 text-gray-500">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        SVG
        input type: "text", placeholder: "Search records..."
      end
    end

    div class: "welcome-message" do
      h1 "Movie Explorer+ Admin"
      p I18n.t("active_admin.dashboard_welcome.call_to_action")
    end

    div class: "dashboard-container" do
      # Recent Movies
      div class: "dashboard-panel" do
        div class: "panel-title" do
          raw <<-SVG
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-5-7l-3 3.5L8 12l-3 3h14l-4-4z"/>
            </svg>
          SVG
          span "Recent Movies"
        end
        div class: "panel-content" do
          ul do
            Movie.order(created_at: :desc).limit(5).each do |movie|
              li do
                if movie.poster.present?
                  image_tag movie.poster, class: "thumbnail"
                else
                  raw <<-SVG
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                  SVG
                end
                div do
                  link_to movie.title, admin_movie_path(movie)
                  div class: "metric-label" do
                    "#{movie.genre} (#{movie.release_year})"
                  end
                end
              end
            end
          end
        end
      end

      # Movie Metrics
      div class: "dashboard-panel" do
        div class: "panel-title" do
          raw <<-SVG
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <path d="M3 3v18h18V3H3zm16 16H5V5h14v14zM7 7h2v2H7V7zm4 0h2v2h-2V7zm4 0h2v2h-2V7z"/>
            </svg>
          SVG
          span "Movie Metrics"
        end
        div class: "panel-content" do
          div class: "flex justify-between mb-4" do
            div do
              span class: "metric" do
                Movie.count
              end
              div class: "metric-label" do
                "Total Movies"
              end
            end
            div do
              span class: "metric" do
                Movie.where(premium: true).count
              end
              div class: "metric-label" do
                "Premium Movies"
              end
            end
          end
          div do
            span class: "metric" do
              Movie.where("created_at >= ?", 1.month.ago).count
            end
            div class: "metric-label" do
              "New Movies (Last 30 Days)"
            end
          end
        end
      end

      # Recent Users
      div class: "dashboard-panel" do
        div class: "panel-title" do
          raw <<-SVG
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
            </svg>
          SVG
          span "Recent Users"
        end
        div class: "panel-content" do
          ul do
            User.order(created_at: :desc).limit(5).each do |user|
              li do
                raw <<-SVG
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                SVG
                div do
                  link_to user.email, admin_user_path(user)
                  div class: "metric-label" do
                    user.role.capitalize
                  end
                end
              end
            end
          end
        end
      end

      # Admin Users
      div class: "dashboard-panel" do
        div class: "panel-title" do
          raw <<-SVG
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
            </svg>
          SVG
          span "Admin Users"
        end
        div class: "panel-content" do
          ul do
            AdminUser.order(created_at: :desc).limit(3).each do |admin|
              li do
                raw <<-SVG
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                SVG
                link_to admin.email, admin_admin_user_path(admin)
              end
            end
          end
        end
      end

#       # Subscription Plans
#       div class: "dashboard-panel" do
#         div class: "panel-title" do
#           raw <<-SVG
#             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
#               <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 14H4V6h16v12zm-8-2c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z"/>
#             </svg>
#           SVG
#           span "Subscription Plans"
#         end
#         div class: "panel-content" do
#           ul do
#             SubscriptionPlan.order(created_at: :desc).limit(3).each do |plan|
#               li do
#                 raw <<-SVG
#                   <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
#                     <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
#                   </svg>
#                 SVG
#                 div do
#                   link_to plan.name, admin_subscription_plan_path(plan)
#                   div class: "metric-label" do
#                     "#{plan.plan_type.capitalize} ($#{plan.price})"
#                   end
#                 end
#               end
#             end
#           end
#         end
#       end

#       # Subscription Metrics
#       div class: "dashboard-panel" do
#         div class: "panel-title" do
#           raw <<-SVG
#             <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
#               <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10H7v-2h10v2zm0-4H7V7h10v2z"/>
#             </svg>
#           SVG
#           span "Subscription Metrics"
#         end
#         div class: "panel-content" do
#           div class: "flex justify-between mb-4" do
#             div do
#               span class: "metric" do
#                 UserSubscription.where(status: :active).count
#               end
#               div class: "metric-label" do
#                 "Active Subscriptions"
#               end
#             end
#             div do
#               span class: "metric" do
#                 UserSubscription.count
#               end
#               div class: "metric-label" do
#                 "Total Subscriptions"
#               end
#             end
#           end
#           div do
#             span class: "metric" do
#               UserSubscription.where("start_date >= ?", 1.month.ago).count
#             end
#             div class: "metric-label" do
#               "New Subscriptions (Last 30 Days)"
#             end
#           end
#         end
#       end
    end
  end
end
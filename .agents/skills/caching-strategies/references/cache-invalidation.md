# Estratégias de cache: invalidação de cache

## Expiração baseada no tempo

```ruby
Rails.cache.fetch("key", expires_in: 1.hour) { ... }
```

## Expiração baseada em chave

```ruby
# Cache key includes timestamp, auto-expires when model changes
cache_key = "event/#{event.id}-#{event.updated_at.to_i}"
Rails.cache.fetch(cache_key) { ... }
```

## Invalidação Manual

### Em callbacks de model

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  after_commit :invalidate_caches

  private

  def invalidate_caches
    Rails.cache.delete("featured_events")
    Rails.cache.delete_matched("dashboard/#{account_id}/*")
  end
end
```

### Em Service Objects

```ruby
class Events::UpdateService
  def call(event, params)
    event.update!(params)
    invalidate_related_caches(event)
    success(event)
  end

  private

  def invalidate_related_caches(event)
    Rails.cache.delete("event_count/#{event.account_id}")
    DashboardStatsService.new.invalidate(account: event.account)
  end
end
```

## Exclusão baseada em padrão

```ruby
# Delete all keys matching pattern (Redis only)
Rails.cache.delete_matched("dashboard/*")

# For Solid Cache / Memory Store, use namespaced keys
Rails.cache.delete("dashboard/#{account_id}/stats")
Rails.cache.delete("dashboard/#{account_id}/events")
```

## Toque para invalidação de cascata (boneca russa)

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :event, touch: true  # Updates event.updated_at when comment changes
end

# app/models/event_vendor.rb
class EventVendor < ApplicationRecord
  belongs_to :event, touch: true
  belongs_to :vendor
end
```

## Cache de Contador

### Cache de contador integrado

```ruby
# Migration
add_column :events, :vendors_count, :integer, default: 0, null: false

# Model
class Vendor < ApplicationRecord
  belongs_to :event, counter_cache: true
end

# Usage (no query needed)
event.vendors_count
```

### Cache de contador personalizado

```ruby
class Event < ApplicationRecord
  after_commit :update_account_counters

  private

  def update_account_counters
    account.update_columns(
      events_count: account.events.count,
      active_events_count: account.events.active.count
    )
  end
end
```

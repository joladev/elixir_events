# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ElixirEvents is a Phoenix LiveView application for managing and displaying community events in the Elixir ecosystem. It features event submission, admin approval, RSS feeds, and location-based filtering.

## Development Commands

```bash
# Setup and install dependencies
mix setup

# Start development server
mix phx.server
# or with IEx
iex -S mix phx.server

# Run tests
mix test
# Run a specific test file
mix test test/path/to/test_file.exs

# Format code
mix format

# Code quality
mix credo --strict

# Database operations
mix ecto.create
mix ecto.migrate
mix ecto.reset  # Drop and recreate

# Asset building
mix assets.build
mix assets.deploy  # For production
```

## Code Quality Requirements

**IMPORTANT**: All code changes must be verified with these commands before completion:
1. `mix format` - Ensure code formatting is correct
2. `mix credo --strict` - Verify code quality and best practices
3. `mix test` - Ensure all tests pass

Always run these three commands after making any code changes.

## Architecture Overview

### Core Contexts

1. **Events** (`lib/elixir_events/events.ex`): Main business logic for event management
   - Event CRUD operations
   - Suggestion system for event edits
   - Approval workflow
   - Query builders for different views (front page, RSS, admin)

2. **Accounts** (`lib/elixir_events/accounts.ex`): User authentication and management
   - Email/password authentication
   - Session management
   - User settings and email updates

3. **Distribution** (`lib/elixir_events/distribution.ex`): External integrations
   - Bluesky posting integration

### LiveView Structure

All LiveViews are in `lib/elixir_events_web/live/`:
- `page.ex`: Main event listing with location filtering
- `event.ex`: Individual event display
- `propose.ex`: Event submission form
- `admin.ex`: Admin panel for event approval and management
- `user_login.ex` & `user_settings.ex`: Authentication flows

### Database Schema

Key models:
- **Event**: Core event data with fields for title, dates, location, timezone, type (conference/meetup), approval status, and online_only flag
- **Suggestion**: User-submitted edits to events
- **User**: Authentication and admin access

### Special Features

1. **Slug-based routing**: Events use slugs in format `{title-slug}/{date}` for SEO-friendly URLs
2. **Timezone handling**: All events store timezone info and display in local time
3. **Feature flags**: Using FunWithFlags for feature toggles
4. **RSS feed**: Available at `/rss` for approved events
5. **Markdown support**: Event descriptions support markdown via mdex

### Testing Approach

- Uses ExUnit with Phoenix test helpers
- Test files mirror the lib structure in `test/`
- Fixtures in `test/support/fixtures/`
- Focus on controller and LiveView integration tests
- Use Mimic for mocking. Always put `stub` and `expect` inline in tests. NEVER ADD GLOBAL STUBS.
- When asserting something happened, use `expect` over `stub`.
- Avoid using `setup`, prefer inline calls and anonymous functions for data setup.
- Avoid using `Application.put_env` in tests. That's bad practice and prevents running tests async.

### Asset Pipeline

- Tailwind CSS for styling
- ESBuild for JavaScript bundling
- Assets configured in `assets/` directory

# ElixirEvents

A Phoenix LiveView application for discovering and managing Elixir community events worldwide. ElixirEvents serves as a central hub for conferences, meetups, and online gatherings in the Elixir ecosystem.

## Features

### Event Management
- **Event Submission**: Community members can propose new events
- **Admin Approval System**: Events are reviewed before publication
- **Event Suggestions**: Users can suggest edits to existing events
- **Event Types**: Support for conferences, meetups, and online events
- **Timezone Support**: Events display in their local timezone

### User Experience
- **Location-based Filtering**: Find events near you or in specific regions
- **SEO-friendly URLs**: Events have clean, descriptive URLs
- **Responsive Design**: Works seamlessly on desktop and mobile
- **Markdown Support**: Rich text formatting for event descriptions

### Content Distribution
- **RSS Feed**: Subscribe to approved events via RSS
- **Bluesky Integration**: Automatic posting of new events to Bluesky

### Administrative Features
- **Admin Dashboard**: Comprehensive event management interface
- **Bulk Operations**: Approve or reject multiple events at once
- **Event Editing**: Direct editing of event details
- **Feature Flags**: Toggle features on/off dynamically

## Tech Stack

- **Backend**: Elixir 1.17+ with Phoenix Framework 1.7
- **Frontend**: Phoenix LiveView for real-time interactivity
- **Database**: PostgreSQL
- **Styling**: Tailwind CSS
- **JavaScript**: ESBuild for asset bundling
- **External Services**:
  - Bluesky API for social media posting
  - FunWithFlags for feature management

## Development Setup

### Prerequisites

- Elixir 1.17 or later
- Erlang/OTP 26 or later
- PostgreSQL 14 or later
- Node.js 16 or later (for assets)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/joladev/elixir_events.git
   cd elixir_events
   ```

2. Install dependencies and setup database:
   ```bash
   mix setup
   ```

3. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

   Or with an interactive shell:
   ```bash
   iex -S mix phx.server
   ```

4. Visit [`localhost:4000`](http://localhost:4000) in your browser

## Configuration

### Development Environment

Create a `.env` file in the project root:

```bash
# Database
DATABASE_URL=ecto://postgres:postgres@localhost/elixir_events_dev

# Admin credentials (for seeding)
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=adminpassword123

# Bluesky integration (optional)
BLUESKY_USERNAME=your-handle.bsky.social
BLUESKY_PASSWORD=your-app-password
```

### Production Environment

Required environment variables for production:

```bash
DATABASE_URL=ecto://user:pass@host/database
SECRET_KEY_BASE=your-secret-key-base
PHX_HOST=your-domain.com
PHX_SERVER=true
BLUESKY_USERNAME=your-handle.bsky.social
BLUESKY_PASSWORD=your-app-password
```

## API Endpoints

### Public Routes
- `GET /` - Main event listing
- `GET /event/:slug` - Individual event page
- `GET /propose` - Event submission form
- `GET /rss` - RSS feed of approved events

### Admin Routes (authentication required)
- `GET /admin` - Admin dashboard
- Event approval/rejection actions
- Event editing capabilities

## Database Schema

### Main Tables

- **events** - Core event information
  - Title, description, dates
  - Location details (venue, city, country)
  - Event type (conference/meetup)
  - Approval status
  - Online-only flag

- **suggestions** - User-submitted event edits
  - Linked to original event
  - Contains proposed changes
  - Approval workflow

- **users** - Authentication and authorization
  - Email/password authentication
  - Admin role support

## Architecture

The application follows Phoenix's context-based architecture:

- **Events Context** (`lib/elixir_events/events.ex`): Core business logic
- **Accounts Context** (`lib/elixir_events/accounts.ex`): User management
- **Distribution Context** (`lib/elixir_events/distribution.ex`): External integrations

LiveViews handle the interactive UI components:
- Event listings with real-time filtering
- Form submissions and validations
- Admin interfaces with live updates

## Development Commands

```bash
# Run tests
mix test

# Run specific test file
mix test test/path/to/test_file.exs

# Format code
mix format

# Database operations
mix ecto.create      # Create database
mix ecto.migrate     # Run migrations
mix ecto.reset       # Drop and recreate database

# Asset management
mix assets.build     # Build assets
mix assets.deploy    # Build for production
```

## Deployment

### Using Docker

```bash
# Build the image
docker build -t elixir_events .

# Run with environment variables
docker run -e DATABASE_URL=... -e SECRET_KEY_BASE=... -p 4000:4000 elixir_events
```

### Using Elixir Releases

```bash
# Build a release
MIX_ENV=prod mix release

# Run the release
_build/prod/rel/elixir_events/bin/elixir_events start
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- All tests pass (`mix test`)
- Code is formatted (`mix format`)
- You've added tests for new functionality

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The Elixir community for inspiration and support
- Phoenix Framework team for the excellent web framework
- All contributors who help make this project better

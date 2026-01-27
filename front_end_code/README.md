# Life Schedule - Frontend

React/Next.js frontend application for the Life Schedule app.

## Features

- User authentication (login/register)
- Contact management with birthdays
- Event creation and management
- Event invitations and RSVP tracking
- Event reminders
- Upcoming birthdays view
- Calendar integration

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
Create a `.env.local` file:
```
NEXT_PUBLIC_API_URL=http://localhost:3001
```

3. Run development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000)

## Project Structure

```
front_end_code/
├── src/
│   ├── app/              # Next.js app router pages
│   ├── components/       # React components
│   ├── lib/             # Utilities and API client
│   ├── types/           # TypeScript types
│   └── hooks/           # Custom React hooks
├── public/              # Static assets
└── package.json
```

## API Integration

The frontend connects to the Life Schedule backend API. Make sure the backend is running on the configured port (default: 3001).


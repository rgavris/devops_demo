'use client';

import { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Card,
  CardContent,
} from '@mui/material';
import { eventsAPI } from '@/lib/api';

interface Event {
  id: number;
  title: string;
  date: string;
}

export default function EventsPage() {
  const [events, setEvents] = useState<Event[]>([]);

  useEffect(() => {
    eventsAPI.getAll('/events').then(res => setEvents(res.data));
  }, []);

  return (
    <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Events
      </Typography>

      {events.map(e => (
        <Card key={e.id} sx={{ mb: 2 }}>
          <CardContent>
            <Typography variant="h6">{e.title}</Typography>
            <Typography>
              {new Date(e.date).toLocaleString()}
            </Typography>
          </CardContent>
        </Card>
      ))}
    </Container>
  );
}

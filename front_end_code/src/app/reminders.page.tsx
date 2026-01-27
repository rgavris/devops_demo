'use client';

import { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Card,
  CardContent,
} from '@mui/material';
import { remindersAPI } from '@/lib/api';

interface Reminder {
  id: number;
  text: string;
  remindAt: string;
}

export default function RemindersPage() {
  const [reminders, setReminders] = useState<Reminder[]>([]);

  useEffect(() => {
    remindersAPI.getAll('/reminders').then(res => setReminders(res.data));
  }, []);

  return (
    <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Reminders
      </Typography>

      {reminders.map(r => (
        <Card key={r.id} sx={{ mb: 2 }}>
          <CardContent>
            <Typography variant="h6">{r.text}</Typography>
            <Typography>
              {new Date(r.remindAt).toLocaleString()}
            </Typography>
          </CardContent>
        </Card>
      ))}
    </Container>
  );
}


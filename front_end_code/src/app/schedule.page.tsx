'use client';

import {
  Container,
  Typography,
  Card,
  CardContent,
} from '@mui/material';

export default function SchedulePage() {
  return (
    <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Schedule
      </Typography>

      <Card>
        <CardContent>
          <Typography>
            Calendar view coming soon 📅
          </Typography>
        </CardContent>
      </Card>
    </Container>
  );
}

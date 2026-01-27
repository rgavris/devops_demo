'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  AppBar,
  Toolbar,
} from '@mui/material';
import { Logout, Event, Contacts, CalendarToday } from '@mui/icons-material';
import { authAPI, eventsAPI, contactsAPI } from '@/lib/api';
import Link from 'next/link';

export default function DashboardPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('authToken');
    if (!token) {
      router.push('/login');
    } else {
      setLoading(false);
    }
  }, [router]);

  const handleLogout = () => {
    authAPI.logout();
    router.push('/');
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Life Schedule
          </Typography>
          <Button color="inherit" onClick={handleLogout} startIcon={<Logout />}>
            Logout
          </Button>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Dashboard
        </Typography>

        <Grid container spacing={3} sx={{ mt: 2 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card component={Link} href="/dashboard/events" sx={{ textDecoration: 'none' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Event sx={{ mr: 1, fontSize: 40 }} />
                  <Typography variant="h5">Events</Typography>
                </Box>
                <Typography color="text.secondary">
                  Manage your events and invitations
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card component={Link} href="/dashboard/contacts" sx={{ textDecoration: 'none' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Contacts sx={{ mr: 1, fontSize: 40 }} />
                  <Typography variant="h5">Contacts</Typography>
                </Box>
                <Typography color="text.secondary">
                  Manage your contacts and birthdays
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card component={Link} href="/dashboard/calendar" sx={{ textDecoration: 'none' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <CalendarToday sx={{ mr: 1, fontSize: 40 }} />
                  <Typography variant="h5">Calendar</Typography>
                </Box>
                <Typography color="text.secondary">
                  View your schedule
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} sm={6} md={3}>
            <Card component={Link} href="/dashboard/reminders" sx={{ textDecoration: 'none' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <Event sx={{ mr: 1, fontSize: 40 }} />
                  <Typography variant="h5">Reminders</Typography>
                </Box>
                <Typography color="text.secondary">
                  Manage event reminders
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Container>
    </>
  );
}


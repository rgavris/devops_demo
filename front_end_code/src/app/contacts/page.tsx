'use client';

import { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Card,
  CardContent,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material';
import { contactsAPI } from '@/lib/api';

interface Contact {
  id: number;
  name: string;
  email?: string;
  birthday?: string;
}
export default function ContactsPage() {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [open, setOpen] = useState(false);

  const [form, setForm] = useState({
    name: '',
    email: '',
    birthday: '',
  });

  useEffect(() => {
    loadContacts();
  }, []);

  const loadContacts = async () => {
    const res = await contactsAPI.get('/contacts');
    setContacts(res.data);
  };

  const handleCreate = async () => {
    await contactsAPI.post('/contacts', form);
    setOpen(false);
 setForm({ name: '', email: '', birthday: '' });
    loadContacts();
  };

  return (
    <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Contacts
      </Typography>

      <Button variant="contained" onClick={() => setOpen(true)} sx={{ mb: 3 }}>
        Add Contact
      </Button>

      {contacts.map(c => (
        <Card key={c.id} sx={{ mb: 2 }}>
          <CardContent>
            <Typography variant="h6">{c.name}</Typography>
            {c.email && <Typography>{c.email}</Typography>}
            {c.birthday && <Typography>🎂 {c.birthday}</Typography>}
          </CardContent>
        </Card>
      ))}
 {/* Create Contact Dialog */}
      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogTitle>Create Contact</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            label="Name"
            margin="dense"
            value={form.name}
            onChange={e => setForm({ ...form, name: e.target.value })}
          />
          <TextField
            fullWidth
            label="Email"
            margin="dense"
            value={form.email}
            onChange={e => setForm({ ...form, email: e.target.value })}
          />
          <TextField
            fullWidth
            type="date"
            label="Birthday"
            margin="dense"
            InputLabelProps={{ shrink: true }}
            value={form.birthday}
            onChange={e => setForm({ ...form, birthday: e.target.value })}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreate}>
            Create
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
}


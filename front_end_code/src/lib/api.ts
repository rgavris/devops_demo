import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export interface User {
  id: number;
  firstName: string;
  lastName: string;
  username: string;
}

export interface Contact {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  userId: number;
  birthMonth?: number;
  birthDay?: number;
  birthYear?: number;
}

export interface Event {
  id: number;
  name: string;
  address: string;
  time: string;
  userId: number;
}

export interface EventInvitation {
  id: number;
  eventId: number;
  contactId: number;
  rsvpStatus: 'pending' | 'attending' | 'maybe' | 'declined';
  respondedAt: string | null;
  responseNote: string | null;
  isManualResponse: boolean;
  contact?: Contact;
}

export interface EventReminder {
  id: number;
  eventId: number;
  userId: number;
  reminderTime: string;
  reminderType: 'email' | 'sms' | 'notification';
  status: 'pending' | 'sent' | 'failed' | 'cancelled';
  recipientType: 'all_invitees' | 'attending_only' | 'creator_only';
  customMessage: string | null;
  sentAt: string | null;
}

// Auth API
export const authAPI = {
  login: async (username: string, password: string) => {
    const response = await api.post('/login', { username, password });
    if (response.data.token) {
      localStorage.setItem('authToken', response.data.token);
    }
    return response.data;
  },
  register: async (userData: {
    firstName: string;
    lastName: string;
    username: string;
    password: string;
  }) => {
    return api.post('/users', userData);
  },
  logout: () => {
    localStorage.removeItem('authToken');
  },
};

// Contacts API
export const contactsAPI = {
  getAll: () => api.get<Contact[]>('/contacts'),
  create: (contact: Partial<Contact>) => api.post<Contact>('/contacts', contact),
  update: (id: number, contact: Partial<Contact>) =>
    api.put<Contact>(`/contacts/${id}`, contact),
  getUpcomingBirthdays: (days?: number) =>
    api.get<{
      daysAhead: number;
      range: { from: string; to: string };
      count: number;
      contacts: Contact[];
    }>(`/contacts/upcoming-birthdays${days ? `?days=${days}` : ''}`),
  getInvitations: (contactId: number) =>
    api.get<{ contact: Contact; invitations: EventInvitation[] }>(
      `/contacts/${contactId}/invitations`
    ),
};

// Events API
export const eventsAPI = {
  getAll: () => api.get<Event[]>('/getAllMyEvents'),
  create: (event: {
    name: string;
    address: string;
    time: string;
    contactIds?: number[];
  }) => api.post<{ event: Event; invitations: EventInvitation[] }>('/events', event),
  getRSVPs: (eventId: number) =>
    api.get<{
      event: Event;
      stats: {
        total: number;
        attending: number;
        maybe: number;
        declined: number;
        pending: number;
      };
      invitations: EventInvitation[];
    }>(`/events/${eventId}/rsvps`),
  sendInvitations: (eventId: number, contactIds: number[]) =>
    api.post<{ message: string; invitations: EventInvitation[] }>(
      `/events/${eventId}/invitations`,
      { contactIds }
    ),
  updateRSVP: (
    eventId: number,
    contactId: number,
    rsvpStatus: 'attending' | 'maybe' | 'declined',
    responseNote?: string,
    isManualResponse?: boolean
  ) =>
    api.post(`/events/${eventId}/rsvp`, {
      contactId,
      rsvpStatus,
      responseNote,
      isManualResponse,
    }),
};

// Reminders API
export const remindersAPI = {
  create: (
    eventId: number,
    reminder: {
      reminderTime?: string;
      reminderType?: 'email' | 'sms' | 'notification';
      recipientType?: 'all_invitees' | 'attending_only' | 'creator_only';
      customMessage?: string;
      autoCreate?: boolean;
    }
  ) =>
    api.post<{ message: string; reminder?: EventReminder; reminders?: EventReminder[] }>(
      `/events/${eventId}/reminders`,
      reminder
    ),
  getForEvent: (eventId: number) =>
    api.get<{ event: Event; reminders: EventReminder[] }>(
      `/events/${eventId}/reminders`
    ),
  getAll: (upcoming?: boolean, days?: number) =>
    api.get<{ reminders: EventReminder[]; stats: any }>(
      `/reminders${upcoming ? `?upcoming=true${days ? `&days=${days}` : ''}` : ''}`
    ),
  update: (id: number, reminder: Partial<EventReminder>) =>
    api.put<{ message: string; reminder: EventReminder }>(`/reminders/${id}`, reminder),
  cancel: (id: number) =>
    api.delete<{ message: string }>(`/reminders/${id}`),
};

export default api;


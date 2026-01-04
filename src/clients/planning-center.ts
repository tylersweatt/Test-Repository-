import axios, { AxiosInstance } from 'axios';

export interface PlanningCenterConfig {
  appId: string;
  secret: string;
}

export interface Person {
  id: string;
  attributes: {
    name: string;
    first_name: string;
    last_name: string;
    birthdate?: string;
    anniversary?: string;
    gender?: string;
    grade?: number;
    child?: boolean;
    status?: string;
  };
}

export interface Event {
  id: string;
  type: string;
  attributes: {
    name: string;
    starts_at?: string;
    ends_at?: string;
    description?: string;
  };
}

export class PlanningCenterClient {
  private client: AxiosInstance;
  private baseUrl = 'https://api.planningcenteronline.com';

  constructor(config: PlanningCenterConfig) {
    this.client = axios.create({
      baseURL: this.baseUrl,
      auth: {
        username: config.appId,
        password: config.secret,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  async getPeople(params?: { where?: string; per_page?: number }): Promise<Person[]> {
    const response = await this.client.get('/people/v2/people', { params });
    return response.data.data;
  }

  async getPerson(id: string): Promise<Person> {
    const response = await this.client.get(`/people/v2/people/${id}`);
    return response.data.data;
  }

  async getCalendarEvents(params?: { filter?: string; per_page?: number }): Promise<Event[]> {
    const response = await this.client.get('/calendar/v2/events', { params });
    return response.data.data;
  }

  async getEvent(id: string): Promise<Event> {
    const response = await this.client.get(`/calendar/v2/events/${id}`);
    return response.data.data;
  }

  async getServiceTypes(): Promise<any[]> {
    const response = await this.client.get('/services/v2/service_types');
    return response.data.data;
  }

  async getPlans(serviceTypeId: string, params?: { filter?: string; per_page?: number }): Promise<any[]> {
    const response = await this.client.get(`/services/v2/service_types/${serviceTypeId}/plans`, { params });
    return response.data.data;
  }

  async getCheckIns(params?: { where?: string; per_page?: number }): Promise<any[]> {
    const response = await this.client.get('/check-ins/v2/check_ins', { params });
    return response.data.data;
  }

  async getGroups(params?: { where?: string; per_page?: number }): Promise<any[]> {
    const response = await this.client.get('/groups/v2/groups', { params });
    return response.data.data;
  }

  async searchPeople(query: string): Promise<Person[]> {
    return this.getPeople({ where: `search_name=${encodeURIComponent(query)}` });
  }
}

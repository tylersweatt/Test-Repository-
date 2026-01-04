import axios, { AxiosInstance } from 'axios';

export interface CraftConfig {
  apiToken: string;
}

export interface CraftDocument {
  id: string;
  spaceId: string;
  title: string;
  content: CraftBlock[];
  createdAt: string;
  updatedAt: string;
}

export interface CraftBlock {
  id: string;
  type: string;
  content?: string;
  subblocks?: CraftBlock[];
  style?: {
    textStyle?: string;
    state?: string;
  };
}

export interface CraftSpace {
  id: string;
  name: string;
  type: string;
}

export class CraftClient {
  private client: AxiosInstance;
  private baseUrl = 'https://api.craft.do/v1';

  constructor(config: CraftConfig) {
    this.client = axios.create({
      baseURL: this.baseUrl,
      headers: {
        'Authorization': `Bearer ${config.apiToken}`,
        'Content-Type': 'application/json',
      },
    });
  }

  async getSpaces(): Promise<CraftSpace[]> {
    const response = await this.client.get('/spaces');
    return response.data.spaces || [];
  }

  async getDocument(documentId: string): Promise<CraftDocument> {
    const response = await this.client.get(`/documents/${documentId}`);
    return response.data;
  }

  async getDocumentsInSpace(spaceId: string): Promise<CraftDocument[]> {
    const response = await this.client.get(`/spaces/${spaceId}/documents`);
    return response.data.documents || [];
  }

  async createDocument(spaceId: string, title: string, content: CraftBlock[]): Promise<CraftDocument> {
    const response = await this.client.post('/documents', {
      spaceId,
      title,
      content,
    });
    return response.data;
  }

  async updateDocument(documentId: string, updates: { title?: string; content?: CraftBlock[] }): Promise<CraftDocument> {
    const response = await this.client.patch(`/documents/${documentId}`, updates);
    return response.data;
  }

  async appendToDocument(documentId: string, blocks: CraftBlock[]): Promise<CraftDocument> {
    const document = await this.getDocument(documentId);
    const updatedContent = [...document.content, ...blocks];
    return this.updateDocument(documentId, { content: updatedContent });
  }

  async searchDocuments(query: string, spaceId?: string): Promise<CraftDocument[]> {
    const params: any = { query };
    if (spaceId) {
      params.spaceId = spaceId;
    }
    const response = await this.client.get('/search', { params });
    return response.data.documents || [];
  }

  createTextBlock(text: string, style?: string): CraftBlock {
    return {
      id: this.generateId(),
      type: 'textBlock',
      content: text,
      style: style ? { textStyle: style } : undefined,
    };
  }

  createHeadingBlock(text: string, level: number = 1): CraftBlock {
    return {
      id: this.generateId(),
      type: 'textBlock',
      content: text,
      style: { textStyle: `heading${level}` },
    };
  }

  createListBlock(items: string[], ordered: boolean = false): CraftBlock {
    return {
      id: this.generateId(),
      type: ordered ? 'numberedListBlock' : 'bulletedListBlock',
      subblocks: items.map(item => this.createTextBlock(item)),
    };
  }

  private generateId(): string {
    return `block_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

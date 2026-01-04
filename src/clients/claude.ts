import Anthropic from '@anthropic-ai/sdk';

export interface ClaudeConfig {
  apiKey: string;
  model?: string;
}

export interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export interface ClaudeResponse {
  content: string;
  usage?: {
    input_tokens: number;
    output_tokens: number;
  };
}

export class ClaudeClient {
  private client: Anthropic;
  private model: string;

  constructor(config: ClaudeConfig) {
    this.client = new Anthropic({
      apiKey: config.apiKey,
    });
    this.model = config.model || 'claude-sonnet-4-5-20250929';
  }

  async sendMessage(message: string, systemPrompt?: string, conversationHistory?: Message[]): Promise<ClaudeResponse> {
    const messages: Anthropic.MessageParam[] = [
      ...(conversationHistory || []).map(msg => ({
        role: msg.role,
        content: msg.content,
      })),
      {
        role: 'user' as const,
        content: message,
      },
    ];

    const response = await this.client.messages.create({
      model: this.model,
      max_tokens: 4096,
      system: systemPrompt,
      messages,
    });

    const textContent = response.content.find(block => block.type === 'text');

    return {
      content: textContent?.type === 'text' ? textContent.text : '',
      usage: {
        input_tokens: response.usage.input_tokens,
        output_tokens: response.usage.output_tokens,
      },
    };
  }

  async analyze(data: any, instructions: string): Promise<string> {
    const prompt = `${instructions}\n\nData to analyze:\n${JSON.stringify(data, null, 2)}`;
    const response = await this.sendMessage(prompt);
    return response.content;
  }

  async summarize(text: string, maxLength?: number): Promise<string> {
    const prompt = maxLength
      ? `Summarize the following text in approximately ${maxLength} words:\n\n${text}`
      : `Provide a concise summary of the following text:\n\n${text}`;

    const response = await this.sendMessage(prompt);
    return response.content;
  }

  async generateDocumentation(data: any, context?: string): Promise<string> {
    const prompt = `Generate clear, well-structured documentation for the following data${context ? ` in the context of: ${context}` : ''}:\n\n${JSON.stringify(data, null, 2)}`;
    const response = await this.sendMessage(prompt);
    return response.content;
  }

  async extractInsights(data: any, focus?: string): Promise<string> {
    const prompt = focus
      ? `Analyze the following data and extract key insights related to: ${focus}\n\nData:\n${JSON.stringify(data, null, 2)}`
      : `Analyze the following data and extract key insights:\n\n${JSON.stringify(data, null, 2)}`;

    const response = await this.sendMessage(prompt);
    return response.content;
  }

  async chat(message: string, history: Message[] = []): Promise<{ response: string; updatedHistory: Message[] }> {
    const response = await this.sendMessage(message, undefined, history);

    const updatedHistory = [
      ...history,
      { role: 'user' as const, content: message },
      { role: 'assistant' as const, content: response.content },
    ];

    return {
      response: response.content,
      updatedHistory,
    };
  }
}

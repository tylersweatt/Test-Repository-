import { PlanningCenterClient } from './clients/planning-center.js';
import { CraftClient } from './clients/craft.js';
import { ClaudeClient } from './clients/claude.js';

export interface IntegratorConfig {
  planningCenter: {
    appId: string;
    secret: string;
  };
  craft: {
    apiToken: string;
  };
  claude: {
    apiKey: string;
    model?: string;
  };
}

export class PCCCIntegrator {
  private pc: PlanningCenterClient;
  private craft: CraftClient;
  private claude: ClaudeClient;

  constructor(config: IntegratorConfig) {
    this.pc = new PlanningCenterClient(config.planningCenter);
    this.craft = new CraftClient(config.craft);
    this.claude = new ClaudeClient(config.claude);
  }

  async syncEventsToDocumentation(spaceId: string, documentTitle?: string): Promise<string> {
    console.log('Fetching events from Planning Center...');
    const events = await this.pc.getCalendarEvents({ per_page: 50 });

    console.log(`Found ${events.length} events. Analyzing with Claude...`);
    const analysis = await this.claude.generateDocumentation(events, 'church calendar events');

    console.log('Creating document in Craft...');
    const title = documentTitle || `Event Summary - ${new Date().toLocaleDateString()}`;
    const blocks = [
      this.craft.createHeadingBlock(title, 1),
      this.craft.createTextBlock(analysis),
    ];

    const document = await this.craft.createDocument(spaceId, title, blocks);
    console.log(`Document created: ${document.id}`);

    return document.id;
  }

  async syncPeopleInsights(spaceId: string, query?: string): Promise<string> {
    console.log('Fetching people data from Planning Center...');
    const people = query
      ? await this.pc.searchPeople(query)
      : await this.pc.getPeople({ per_page: 100 });

    console.log(`Found ${people.length} people. Extracting insights with Claude...`);
    const insights = await this.claude.extractInsights(people, 'demographic patterns and ministry opportunities');

    console.log('Creating insights document in Craft...');
    const title = `People Insights - ${new Date().toLocaleDateString()}`;
    const blocks = [
      this.craft.createHeadingBlock(title, 1),
      this.craft.createTextBlock(insights),
    ];

    const document = await this.craft.createDocument(spaceId, title, blocks);
    console.log(`Document created: ${document.id}`);

    return document.id;
  }

  async generateServicePlanSummary(serviceTypeId: string, spaceId: string): Promise<string> {
    console.log('Fetching service plans from Planning Center...');
    const plans = await this.pc.getPlans(serviceTypeId, { per_page: 20 });

    console.log(`Found ${plans.length} service plans. Generating summary with Claude...`);
    const summary = await this.claude.summarize(JSON.stringify(plans, null, 2));

    console.log('Creating summary document in Craft...');
    const title = `Service Plans Summary - ${new Date().toLocaleDateString()}`;
    const blocks = [
      this.craft.createHeadingBlock(title, 1),
      this.craft.createTextBlock(summary),
    ];

    const document = await this.craft.createDocument(spaceId, title, blocks);
    console.log(`Document created: ${document.id}`);

    return document.id;
  }

  async analyzeAndDocument(
    dataType: 'events' | 'people' | 'groups' | 'service-types',
    spaceId: string,
    analysisPrompt?: string
  ): Promise<string> {
    console.log(`Fetching ${dataType} from Planning Center...`);

    let data: any;
    switch (dataType) {
      case 'events':
        data = await this.pc.getCalendarEvents({ per_page: 50 });
        break;
      case 'people':
        data = await this.pc.getPeople({ per_page: 100 });
        break;
      case 'groups':
        data = await this.pc.getGroups({ per_page: 50 });
        break;
      case 'service-types':
        data = await this.pc.getServiceTypes();
        break;
      default:
        throw new Error(`Unknown data type: ${dataType}`);
    }

    console.log(`Retrieved ${Array.isArray(data) ? data.length : 1} items. Analyzing with Claude...`);
    const analysis = analysisPrompt
      ? await this.claude.analyze(data, analysisPrompt)
      : await this.claude.generateDocumentation(data, dataType);

    console.log('Creating document in Craft...');
    const title = `${dataType.charAt(0).toUpperCase() + dataType.slice(1)} Analysis - ${new Date().toLocaleDateString()}`;
    const blocks = [
      this.craft.createHeadingBlock(title, 1),
      this.craft.createTextBlock(analysis),
    ];

    const document = await this.craft.createDocument(spaceId, title, blocks);
    console.log(`Document created: ${document.id}`);

    return document.id;
  }

  async queryWithContext(question: string, context?: { type: string; id?: string }): Promise<string> {
    let contextData: any = null;

    if (context) {
      console.log(`Fetching context data: ${context.type}`);
      switch (context.type) {
        case 'event':
          contextData = context.id ? await this.pc.getEvent(context.id) : await this.pc.getCalendarEvents({ per_page: 10 });
          break;
        case 'person':
          contextData = context.id ? await this.pc.getPerson(context.id) : await this.pc.getPeople({ per_page: 10 });
          break;
        case 'service-types':
          contextData = await this.pc.getServiceTypes();
          break;
      }
    }

    const prompt = contextData
      ? `Using the following Planning Center data as context:\n\n${JSON.stringify(contextData, null, 2)}\n\nAnswer this question: ${question}`
      : question;

    console.log('Querying Claude...');
    const response = await this.claude.sendMessage(prompt);

    return response.content;
  }

  async updateCraftFromPlanning(documentId: string, dataType: string, params?: any): Promise<void> {
    console.log(`Fetching fresh ${dataType} data from Planning Center...`);

    let data: any;
    if (dataType === 'events') {
      data = await this.pc.getCalendarEvents(params);
    } else if (dataType === 'people') {
      data = await this.pc.getPeople(params);
    }

    console.log('Processing data with Claude...');
    const formatted = await this.claude.generateDocumentation(data, dataType);

    console.log('Updating Craft document...');
    const blocks = [
      this.craft.createHeadingBlock(`Updated: ${new Date().toLocaleString()}`, 2),
      this.craft.createTextBlock(formatted),
    ];

    await this.craft.appendToDocument(documentId, blocks);
    console.log('Document updated successfully');
  }

  getPlanningCenterClient(): PlanningCenterClient {
    return this.pc;
  }

  getCraftClient(): CraftClient {
    return this.craft;
  }

  getClaudeClient(): ClaudeClient {
    return this.claude;
  }
}

# Planning Center + Claude + Craft Integration

A powerful integration tool that connects Planning Center Online, Claude AI, and Craft docs to automate documentation, generate insights, and streamline church management workflows.

## Features

- **Event Sync**: Automatically sync Planning Center events to Craft documentation with AI-generated summaries
- **People Insights**: Analyze demographic data and generate ministry opportunity reports
- **Service Plans**: Create comprehensive summaries of service plans
- **Smart Queries**: Ask questions about your Planning Center data with AI-powered context
- **Auto Documentation**: Generate well-formatted documentation from any Planning Center data
- **Live Updates**: Keep Craft documents synchronized with fresh Planning Center data

## Installation

```bash
npm install
```

## Setup

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Fill in your API credentials:

### Planning Center
- Go to https://api.planningcenteronline.com/oauth/applications
- Create a new Personal Access Token
- Copy the App ID and Secret to your `.env` file

### Craft Docs
- Open Craft Settings > Integrations > API
- Generate an API token
- Copy to your `.env` file

### Claude AI
- Visit https://console.anthropic.com/
- Create an API key
- Copy to your `.env` file

3. Build the project:
```bash
npm run build
```

## Usage

### CLI Commands

#### Sync Events to Craft
```bash
npm run sync-events -- -s <craft-space-id> -t "My Event Summary"
```

#### Analyze People Data
```bash
npm run sync-people -- -s <craft-space-id> -q "youth"
```

#### General Analysis
```bash
npm run analyze -- -t events -s <craft-space-id> -p "Focus on upcoming events"
npm run analyze -- -t people -s <craft-space-id>
npm run analyze -- -t groups -s <craft-space-id>
npm run analyze -- -t service-types -s <craft-space-id>
```

#### Ask Questions
```bash
npm run query -- -q "What events are coming up this month?" -c event
npm run query -- -q "How many active members do we have?" -c person
```

#### Update Documents
```bash
npm run update-doc -- -d <craft-doc-id> -t events
```

#### List Craft Spaces
```bash
npm run list-spaces
```

#### Service Plan Summaries
```bash
npm run service-plans -- -t <service-type-id> -s <craft-space-id>
```

### Programmatic Usage

```typescript
import { PCCCIntegrator, loadConfig } from './src/index.js';

const config = loadConfig();
const integrator = new PCCCIntegrator(config);

// Sync events to documentation
const docId = await integrator.syncEventsToDocumentation('space-id', 'Event Summary');

// Generate people insights
await integrator.syncPeopleInsights('space-id', 'youth ministry');

// Ask questions with context
const answer = await integrator.queryWithContext(
  'What events need volunteers?',
  { type: 'event' }
);

// Access individual clients
const pcClient = integrator.getPlanningCenterClient();
const craftClient = integrator.getCraftClient();
const claudeClient = integrator.getClaudeClient();

// Use clients directly
const events = await pcClient.getCalendarEvents({ per_page: 10 });
const spaces = await craftClient.getSpaces();
const analysis = await claudeClient.analyze(events, 'Identify key dates');
```

## API Reference

### PCCCIntegrator

Main integration class that orchestrates all three services.

**Methods:**
- `syncEventsToDocumentation(spaceId, documentTitle?)` - Sync events to Craft
- `syncPeopleInsights(spaceId, query?)` - Generate people insights
- `generateServicePlanSummary(serviceTypeId, spaceId)` - Create service plan summary
- `analyzeAndDocument(dataType, spaceId, analysisPrompt?)` - Generic data analysis
- `queryWithContext(question, context?)` - Ask AI questions with Planning Center context
- `updateCraftFromPlanning(documentId, dataType, params?)` - Update existing docs

### PlanningCenterClient

Client for Planning Center Online API.

**Methods:**
- `getPeople(params?)` - Get people list
- `getPerson(id)` - Get specific person
- `getCalendarEvents(params?)` - Get calendar events
- `getEvent(id)` - Get specific event
- `getServiceTypes()` - Get service types
- `getPlans(serviceTypeId, params?)` - Get service plans
- `getCheckIns(params?)` - Get check-in data
- `getGroups(params?)` - Get groups
- `searchPeople(query)` - Search for people

### CraftClient

Client for Craft docs API.

**Methods:**
- `getSpaces()` - List all spaces
- `getDocument(documentId)` - Get specific document
- `getDocumentsInSpace(spaceId)` - Get all docs in a space
- `createDocument(spaceId, title, content)` - Create new document
- `updateDocument(documentId, updates)` - Update document
- `appendToDocument(documentId, blocks)` - Append to document
- `searchDocuments(query, spaceId?)` - Search documents
- `createTextBlock(text, style?)` - Create text block
- `createHeadingBlock(text, level?)` - Create heading block
- `createListBlock(items, ordered?)` - Create list block

### ClaudeClient

Client for Claude AI API.

**Methods:**
- `sendMessage(message, systemPrompt?, conversationHistory?)` - Send message to Claude
- `analyze(data, instructions)` - Analyze data with custom instructions
- `summarize(text, maxLength?)` - Summarize text
- `generateDocumentation(data, context?)` - Generate documentation
- `extractInsights(data, focus?)` - Extract insights from data
- `chat(message, history?)` - Interactive chat

## Use Cases

### Weekly Event Summary
Automatically generate and publish weekly event summaries to Craft:
```bash
npm run sync-events -- -s <space-id> -t "This Week's Events"
```

### Ministry Demographics Report
Analyze your congregation's demographics for ministry planning:
```bash
npm run sync-people -- -s <space-id>
```

### Volunteer Coordination
Query about volunteer needs across events:
```bash
npm run query -- -q "Which events need more volunteers this month?" -c event
```

### Service Planning
Generate comprehensive service plan documentation:
```bash
npm run service-plans -- -t <service-type-id> -s <space-id>
```

## Architecture

```
┌─────────────────┐
│ Planning Center │
│   (Data Source) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│   PCCCIntegrator│◄────►│   Claude AI  │
│  (Orchestrator) │      │  (Analysis)  │
└────────┬────────┘      └──────────────┘
         │
         ▼
┌─────────────────┐
│   Craft Docs    │
│ (Documentation) │
└─────────────────┘
```

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## License

MIT
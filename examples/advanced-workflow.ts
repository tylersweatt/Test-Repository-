import { PCCCIntegrator, loadConfig } from '../src/index.js';

/**
 * Advanced workflow example: Weekly ministry report automation
 *
 * This script demonstrates how to:
 * 1. Gather data from multiple Planning Center sources
 * 2. Use Claude to analyze and generate insights
 * 3. Create a comprehensive weekly report in Craft
 */
async function generateWeeklyReport() {
  const config = loadConfig();
  const integrator = new PCCCIntegrator(config);

  console.log('Starting weekly ministry report generation...\n');

  // Get the individual clients for fine-grained control
  const pc = integrator.getPlanningCenterClient();
  const craft = integrator.getCraftClient();
  const claude = integrator.getClaudeClient();

  // Step 1: Gather data from Planning Center
  console.log('Step 1: Gathering data from Planning Center...');
  const [events, people, groups, serviceTypes] = await Promise.all([
    pc.getCalendarEvents({ per_page: 20 }),
    pc.getPeople({ per_page: 50 }),
    pc.getGroups({ per_page: 30 }),
    pc.getServiceTypes(),
  ]);

  console.log(`  - Events: ${events.length}`);
  console.log(`  - People: ${people.length}`);
  console.log(`  - Groups: ${groups.length}`);
  console.log(`  - Service Types: ${serviceTypes.length}\n`);

  // Step 2: Use Claude to analyze the data
  console.log('Step 2: Analyzing data with Claude AI...');

  const eventAnalysis = await claude.analyze(
    events,
    'Summarize upcoming events, highlighting any that need attention or volunteers'
  );

  const peopleInsights = await claude.extractInsights(
    people,
    'demographic trends and new member engagement'
  );

  const groupHealth = await claude.analyze(
    groups,
    'Assess group health, identify groups that may need support or are thriving'
  );

  console.log('  - Event analysis complete');
  console.log('  - People insights generated');
  console.log('  - Group health assessment complete\n');

  // Step 3: Create structured Craft document
  console.log('Step 3: Creating comprehensive report in Craft...');

  const spaces = await craft.getSpaces();
  const reportSpace = spaces[0]; // Use first space or select specific one

  const reportBlocks = [
    craft.createHeadingBlock('Weekly Ministry Report', 1),
    craft.createTextBlock(`Generated on: ${new Date().toLocaleDateString()}`),

    craft.createHeadingBlock('Upcoming Events', 2),
    craft.createTextBlock(eventAnalysis),

    craft.createHeadingBlock('People & Engagement', 2),
    craft.createTextBlock(peopleInsights),

    craft.createHeadingBlock('Group Health', 2),
    craft.createTextBlock(groupHealth),

    craft.createHeadingBlock('Action Items', 2),
  ];

  // Generate action items based on all analyses
  const actionItemsPrompt = `Based on these analyses:

Events: ${eventAnalysis}
People: ${peopleInsights}
Groups: ${groupHealth}

Generate a bulleted list of 5-7 specific action items for church leadership this week.`;

  const actionItems = await claude.sendMessage(actionItemsPrompt);
  reportBlocks.push(craft.createTextBlock(actionItems.content));

  const document = await craft.createDocument(
    reportSpace.id,
    `Weekly Ministry Report - ${new Date().toLocaleDateString()}`,
    reportBlocks
  );

  console.log(`✓ Report created successfully!`);
  console.log(`  Document ID: ${document.id}\n`);

  return document.id;
}

/**
 * Advanced workflow: Interactive data exploration
 */
async function interactiveExploration() {
  const config = loadConfig();
  const integrator = new PCCCIntegrator(config);

  console.log('Interactive Planning Center data exploration...\n');

  // Ask a series of related questions
  const questions = [
    'What are the top 3 upcoming events?',
    'Which events might need more volunteer support?',
    'Are there any scheduling conflicts in the calendar?',
  ];

  let conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }> = [];

  for (const question of questions) {
    console.log(`Q: ${question}`);

    const answer = await integrator.queryWithContext(question, { type: 'event' });
    console.log(`A: ${answer}\n`);

    conversationHistory.push(
      { role: 'user', content: question },
      { role: 'assistant', content: answer }
    );
  }
}

/**
 * Advanced workflow: Automated sync with scheduling
 */
async function scheduledSync() {
  const config = loadConfig();
  const integrator = new PCCCIntegrator(config);

  console.log('Running scheduled data sync...\n');

  try {
    // Sync different types of data to different documents
    const [eventsDoc, peopleDoc, groupsDoc] = await Promise.all([
      integrator.analyzeAndDocument('events', 'your-space-id'),
      integrator.analyzeAndDocument('people', 'your-space-id'),
      integrator.analyzeAndDocument('groups', 'your-space-id'),
    ]);

    console.log('Sync complete!');
    console.log(`  Events: ${eventsDoc}`);
    console.log(`  People: ${peopleDoc}`);
    console.log(`  Groups: ${groupsDoc}`);
  } catch (error) {
    console.error('Sync failed:', error);
  }
}

// Run the appropriate workflow
const workflow = process.argv[2] || 'weekly-report';

switch (workflow) {
  case 'weekly-report':
    generateWeeklyReport().catch(console.error);
    break;
  case 'explore':
    interactiveExploration().catch(console.error);
    break;
  case 'sync':
    scheduledSync().catch(console.error);
    break;
  default:
    console.log('Available workflows: weekly-report, explore, sync');
}

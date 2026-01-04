#!/usr/bin/env node
import { Command } from 'commander';
import { loadConfig } from './config.js';
import { PCCCIntegrator } from './integrator.js';

const program = new Command();

program
  .name('pccc-integrator')
  .description('Planning Center + Claude + Craft integration tool')
  .version('1.0.0');

program
  .command('sync-events')
  .description('Sync Planning Center events to a Craft document')
  .requiredOption('-s, --space-id <id>', 'Craft space ID')
  .option('-t, --title <title>', 'Document title')
  .action(async (options) => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      const docId = await integrator.syncEventsToDocumentation(options.spaceId, options.title);
      console.log(`\n✓ Success! Document ID: ${docId}`);
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('sync-people')
  .description('Sync Planning Center people data and generate insights in Craft')
  .requiredOption('-s, --space-id <id>', 'Craft space ID')
  .option('-q, --query <query>', 'Search query for people')
  .action(async (options) => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      const docId = await integrator.syncPeopleInsights(options.spaceId, options.query);
      console.log(`\n✓ Success! Document ID: ${docId}`);
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('analyze')
  .description('Analyze Planning Center data and create Craft documentation')
  .requiredOption('-t, --type <type>', 'Data type: events, people, groups, service-types')
  .requiredOption('-s, --space-id <id>', 'Craft space ID')
  .option('-p, --prompt <prompt>', 'Custom analysis prompt for Claude')
  .action(async (options) => {
    try {
      const validTypes = ['events', 'people', 'groups', 'service-types'];
      if (!validTypes.includes(options.type)) {
        throw new Error(`Invalid type. Must be one of: ${validTypes.join(', ')}`);
      }

      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      const docId = await integrator.analyzeAndDocument(
        options.type as any,
        options.spaceId,
        options.prompt
      );
      console.log(`\n✓ Success! Document ID: ${docId}`);
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('query')
  .description('Ask Claude a question with Planning Center data as context')
  .requiredOption('-q, --question <question>', 'Question to ask')
  .option('-c, --context <type>', 'Context type: event, person, service-types')
  .option('-i, --id <id>', 'Specific item ID for context')
  .action(async (options) => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);

      const context = options.context
        ? { type: options.context, id: options.id }
        : undefined;

      const answer = await integrator.queryWithContext(options.question, context);
      console.log(`\n${answer}\n`);
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('update-doc')
  .description('Update a Craft document with fresh Planning Center data')
  .requiredOption('-d, --doc-id <id>', 'Craft document ID')
  .requiredOption('-t, --type <type>', 'Data type: events, people')
  .action(async (options) => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      await integrator.updateCraftFromPlanning(options.docId, options.type);
      console.log('\n✓ Document updated successfully!');
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('list-spaces')
  .description('List all Craft spaces')
  .action(async () => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      const craft = integrator.getCraftClient();
      const spaces = await craft.getSpaces();

      console.log('\nCraft Spaces:');
      spaces.forEach((space) => {
        console.log(`  - ${space.name} (ID: ${space.id}) [${space.type}]`);
      });
      console.log('');
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program
  .command('service-plans')
  .description('Generate summary of service plans')
  .requiredOption('-t, --service-type-id <id>', 'Planning Center service type ID')
  .requiredOption('-s, --space-id <id>', 'Craft space ID')
  .action(async (options) => {
    try {
      const config = loadConfig();
      const integrator = new PCCCIntegrator(config);
      const docId = await integrator.generateServicePlanSummary(
        options.serviceTypeId,
        options.spaceId
      );
      console.log(`\n✓ Success! Document ID: ${docId}`);
    } catch (error) {
      console.error('Error:', error instanceof Error ? error.message : error);
      process.exit(1);
    }
  });

program.parse();

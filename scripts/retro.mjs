#!/usr/bin/env zx

// Search Obsidian vault for #retro tags within a date range.
// Usage: zx retro.mjs [--from YYYY-MM-DD] [--to YYYY-MM-DD]
// Defaults: from = 1 month ago, to = today

const VAULT = `${os.homedir()}/Documents/notes`;
const OBSIDIAN = "/Applications/Obsidian.app/Contents/MacOS/Obsidian";

function parseDate(str) {
  const d = new Date(str + "T00:00:00");
  if (isNaN(d)) throw new Error(`Invalid date: ${str}`);
  return d;
}

function formatDate(d) {
  return d.toISOString().slice(0, 10);
}

function dateFromFilename(filepath) {
  const match = filepath.match(/(\d{4}-\d{2}-\d{2})/);
  return match ? parseDate(match[1]) : null;
}

// Help
if (argv.help || argv.h) {
  console.log(`
${chalk.bold("retro")} — Search Obsidian notes for #retro tags

${chalk.dim("Usage:")}
  retro [options]

${chalk.dim("Options:")}
  --from YYYY-MM-DD   Start date (default: 1 month ago)
  --to YYYY-MM-DD     End date (default: today)
  --help, -h          Show this help

${chalk.dim("Examples:")}
  retro                                  Last month to today
  retro --from 2026-03-01                Since March 1st
  retro --from 2026-02-01 --to 2026-02-28   Just February

${chalk.dim("How to use:")}
  Add ${chalk.cyan("#retro")} anywhere in your Obsidian notes to tag items
  for the next retro. Works in daily notes, ticket notes, etc.

  Example: ${chalk.dim("- #retro Jasper for help debugging the ZND deploy")}
`);
  process.exit(0);
}

// Parse flags
const fromFlag = argv.from;
const toFlag = argv.to;

const to = toFlag ? parseDate(toFlag) : new Date();
const from = fromFlag
  ? parseDate(fromFlag)
  : new Date(to.getFullYear(), to.getMonth() - 1, to.getDate());

console.log(
  chalk.dim(`Searching for #retro tags from ${formatDate(from)} to ${formatDate(to)}`)
);

// Search vault for #retro tag
const result =
  await $`${OBSIDIAN} tag name=retro 2>&1 | grep -v "Loading\\|installer"`.nothrow();

const output = result.stdout.trim();
if (!output || output.includes("No matches")) {
  console.log(chalk.yellow("No #retro tags found."));
  process.exit(0);
}

// Parse results — Obsidian search returns "path/to/file.md" lines
const lines = output.split("\n").filter((l) => l.trim());

const matches = [];
for (const line of lines) {
  const filepath = line.trim();
  const fileDate = dateFromFilename(filepath);

  // If we can extract a date, filter by range
  if (fileDate && (fileDate < from || fileDate > to)) continue;

  // If no date in filename, include it (could be a non-daily note)
  const fullPath = filepath.startsWith("/") ? filepath : `${VAULT}/${filepath}`;

  // Read the file and find lines with #retro
  let content;
  try {
    content = await fs.readFile(fullPath, "utf-8");
  } catch {
    // Try without vault prefix
    try {
      content = await fs.readFile(filepath, "utf-8");
    } catch {
      continue;
    }
  }

  const retroLines = content
    .split("\n")
    .filter((l) => l.includes("#retro"))
    .map((l) => l.trim());

  if (retroLines.length > 0) {
    matches.push({
      file: filepath,
      date: fileDate ? formatDate(fileDate) : null,
      lines: retroLines,
    });
  }
}

// Sort by date (most recent first), undated at the end
matches.sort((a, b) => {
  if (a.date && b.date) return b.date.localeCompare(a.date);
  if (a.date) return -1;
  return 1;
});

if (matches.length === 0) {
  console.log(chalk.yellow("No #retro tags found in the date range."));
  process.exit(0);
}

for (const m of matches) {
  const header = m.date ? `${m.date} — ${m.file}` : m.file;
  console.log(chalk.bold.cyan(header));
  for (const line of m.lines) {
    console.log(`  ${line}`);
  }
  console.log();
}

console.log(chalk.dim(`${matches.length} file(s) with #retro tags`));

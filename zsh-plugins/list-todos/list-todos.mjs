#!/usr/bin/env zx

const help = `
Lists TODO items grouped by their text content.

Usage: list-todos [options] [name]

Arguments:
  name              Search pattern for TODO(name) (default: "jesse")

Options:
  -a, --all         Find all TODOs, not just TODO(name)
  -d, --dir <path>  Directory to search (default: current directory)
  -t, --type <ext>  File type filter, e.g. "ts", "go", "py" (can repeat)
  -c, --count       Show count of occurrences per group instead of file list
  -f, --files-only  Show only unique file paths, no grouping
  -h, --help        Show this help
`.trim();

if (argv.help || argv.h) {
    console.log(help);
    process.exit(0);
}

const all = argv.all || argv.a || false;
const name = argv._[0] || "jesse";
const dir = argv.dir || argv.d || ".";
const types = [].concat(argv.type || argv.t || []).filter(Boolean);
const countOnly = argv.count || argv.c || false;
const filesOnly = argv["files-only"] || argv.f || false;

// Build ripgrep args — capture the full TODO match including any (name) tag
const pattern = all ? "TODO(\\([^)]+\\))?:?\\s*(.*)" : `TODO\\(${name}\\):?\\s*(.*)`;
const rgArgs = [
    pattern,
    "--no-heading",
    "-o",
    "--with-filename",
    "--line-number",
];
for (const t of types) {
    rgArgs.push("--type", t);
}
rgArgs.push(dir);

let result;
try {
    result = await $`rg ${rgArgs}`.quiet();
} catch (e) {
    if (e.exitCode === 1) {
        console.log(all ? "No TODO items found." : `No TODO(${name}) items found.`);
        process.exit(0);
    }
    throw e;
}

const lines = result.stdout.trim().split("\n").filter(Boolean);

// Parse lines: file:line:matched_text
// Extract tag (e.g. "PROJ-123") and comment from the matched TODO text
const todoPattern = /TODO(?:\(([^)]+)\))?:?\s*(.*)/;
const entries = lines.map((line) => {
    const firstColon = line.indexOf(":");
    const secondColon = line.indexOf(":", firstColon + 1);
    const file = line.slice(0, firstColon);
    const lineNum = line.slice(firstColon + 1, secondColon);
    const raw = line.slice(secondColon + 1).trim();
    const match = raw.match(todoPattern);
    const tag = match?.[1] || null;
    const comment = (match?.[2] || raw).trim();
    return {file, lineNum, tag, comment, location: `${file}:${lineNum}`};
});

// --files-only mode
if (filesOnly) {
    const uniqueFiles = [...new Set(entries.map((e) => e.file))].sort();
    for (const f of uniqueFiles) {
        console.log(f);
    }
    process.exit(0);
}

// Group by tag if present, otherwise by normalized comment
const groups = new Map();
for (const entry of entries) {
    const key = entry.tag
        ? entry.tag.toLowerCase()
        : entry.comment.toLowerCase().replace(/[.?!,;:]*$/, "");
    const label = entry.tag ? entry.tag : entry.comment;
    if (!groups.has(key)) {
        groups.set(key, {label, locations: []});
    }
    groups.get(key).locations.push({location: entry.location, comment: entry.comment});
}

// Sort groups alphabetically
const sorted = [...groups.entries()].sort((a, b) => a[0].localeCompare(b[0]));

for (const [, group] of sorted) {
    if (countOnly) {
        console.log(`${group.locations.length}\t${group.label}`);
    } else {
        console.log(`## ${group.label}`);
        for (const {location} of group.locations) {
            console.log(`- ${location}`);
        }
        console.log();
    }
}

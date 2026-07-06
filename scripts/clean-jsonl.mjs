#!/usr/bin/env zx

const input = argv._[0];
if (!input) {
    console.error("Usage: clean-jsonl <input.json>");
    process.exit(1);
}
const output = input.replace(/\.json$/, "-clean.json");

const lines = (await fs.readFile(input, "utf-8")).split("\n");

let skipped = 0;
const valid = lines.filter((line) => {
    if (!line.trim()) return false;
    try {
        JSON.parse(line);
        return true;
    } catch {
        skipped++;
        return false;
    }
});

await fs.writeFile(output, valid.join("\n") + "\n");
console.log(`Wrote ${valid.length} valid JSON lines to ${output} (skipped ${skipped} non-JSON lines)`);

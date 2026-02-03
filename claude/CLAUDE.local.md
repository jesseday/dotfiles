# Local rules

## Session Notes

When asked to summarize a session or interaction, there are two types of summaries:

### Daily Summary
- Filename: `YYYY-MM-DD.md` (e.g., `notes/summaries/2026-01-23.md`)
- Keep these brief: high-level overview of the day's work
- If the file already exists, add new information under the existing content
- Include: topics worked on, key outcomes, any blockers or follow-ups

### Ticket Summary
- Filename: `DIST-xxxx.md` (e.g., `notes/summaries/DIST-6725.md`)
- More detailed than daily summaries
- If the file already exists, create a heading for today's date (e.g., `## 2026-01-23`) if none exists, then append under that heading
- Include: what was worked on, key decisions made, code references, and any open questions or next steps

### General Rules
- When asked to write a summary of today's work, first run the `date` command to determine the current date
- Write notes in markdown format
- Save to `notes/summaries/` directory (which is a symlink to a directory outside this repo)
- Use clear headings, bullet points, and code references as appropriate

When asked to review "yesterday's notes", "recent notes", or similar, read the relevant dated notes files.

These notes files should never be committed to the repository.

## Questions

When asked to "write down a question" or similar:
- The notes directory contains a symlink called `questions` pointing to a questions directory
- Create a new file in `notes/questions/` named `NNNN. [brief-question].md` (4-digit number with leading zeros, e.g., `0001. why-does-auth-fail.md`)
- Increment the number based on existing files to maintain order
- Use the template file in the questions directory as the format for new questions
- If we have just discovered the answer during the session, include the answer in the file as well

These question files should never be committed to the repository.

## Date Command

When asked for today's date, run the `date` command to get the current date rather than relying on any cached or provided date information.

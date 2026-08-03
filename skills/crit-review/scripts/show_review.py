#!/usr/bin/env python3
"""Print crit review comments grouped by file.

Reads a crit review.json and prints each comment's id, location, body,
anchor, and reply thread so you can act on them without writing an inline
parser each round.

Usage:
  show_review.py [REVIEW_JSON]      # defaults to the most recently updated
                                    # review under ~/.crit/reviews/*/review.json
  show_review.py --all [REVIEW_JSON]   # include resolved comments too
  show_review.py --ids [REVIEW_JSON]   # print only unresolved comment ids

By default only unresolved comments are shown (resolved != true), which is
what a review round asks you to address. Reply threads are always printed in
full so you can tell a fresh request from a conversational follow-up.
"""
import argparse
import glob
import json
import os
import sys


def find_latest_review():
    pattern = os.path.expanduser("~/.crit/reviews/*/review.json")
    matches = glob.glob(pattern)
    if not matches:
        return None
    return max(matches, key=os.path.getmtime)


def iter_comments(review):
    """Yield (file_label, comment) for every comment in the review."""
    for file_path, file_data in review.get("files", {}).items():
        for comment in file_data.get("comments", []):
            yield file_path, comment
    for comment in review.get("review_comments", []):
        yield "(review-level)", comment


def print_comment(file_label, comment):
    resolved = comment.get("resolved")
    status = "RESOLVED" if resolved else "OPEN"
    lines = f"{comment.get('start_line')}-{comment.get('end_line')}"
    print("-" * 72)
    print(f"[{status}] {comment.get('id')}  {file_label}  L{lines}  "
          f"(round {comment.get('review_round')}, scope {comment.get('scope')})")
    if comment.get("anchor"):
        print(f"  anchor: {comment['anchor']!r}")
    print(f"  body: {comment.get('body')}")
    replies = comment.get("replies", [])
    if replies:
        print(f"  replies ({len(replies)}):")
        for reply in replies:
            print(f"    - {reply.get('author')} "
                  f"(round {reply.get('review_round')}): {reply.get('body')}")


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("review", nargs="?", help="path to review.json")
    parser.add_argument("--all", action="store_true",
                        help="include resolved comments")
    parser.add_argument("--ids", action="store_true",
                        help="print only unresolved comment ids, one per line")
    args = parser.parse_args()

    review_path = args.review or find_latest_review()
    if not review_path or not os.path.exists(review_path):
        sys.exit(f"review.json not found: {review_path or '(none under ~/.crit/reviews)'}")

    with open(review_path) as f:
        review = json.load(f)

    comments = list(iter_comments(review))
    shown = [(fl, c) for fl, c in comments
             if args.all or not c.get("resolved")]

    if args.ids:
        for _, comment in shown:
            print(comment.get("id"))
        return

    print(f"review:   {review_path}")
    print(f"branch:   {review.get('branch')}  (base {review.get('base_ref')})")
    print(f"round:    {review.get('review_round')}   updated {review.get('updated_at')}")
    total = len(comments)
    print(f"comments: {len(shown)} shown / {total} total"
          f"{' (open only)' if not args.all else ''}")
    if not shown:
        print("\nNo comments to address. Run `crit` to advance the round.")
        return
    for file_label, comment in shown:
        print_comment(file_label, comment)


if __name__ == "__main__":
    main()

# FoundationModelPlay

Small experiments with Apple's Foundation Models framework.

## Structured Output And Tools

One important learning from this project: structured outputs are not reliably generated when the same `LanguageModelSession` also has tools registered.

In the itinerary experiment, a tool-enabled session could successfully call the MapKit point-of-interest tool several times, but then sometimes failed to produce the requested `@Generable` model shape. On the iPhone simulator this showed up as errors like:

```text
GeneratedContent does not contain a property 'title'.
Content: {}
```

The more stable pattern is to split the work into separate sessions:

1. Use a tool-enabled research session to call tools and summarize results in plain English.
2. Pass that plain-English summary into a second session.
3. Keep the second session tool-free and use it only for structured output generation.

That keeps tool orchestration separate from strict schema generation. It also makes tool failures easier to handle: if a lookup fails, convert it into plain context such as "no results found" instead of letting the error abort structured generation.

# DeepStream (DSKK)

**An AI-powered community where your unfinished AI conversations find the people who can actually help.**

Built from zero by two young founders — full-time, self-funded, 2.5 years and counting.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey)]()

## 🎬 Meet the team & the product

- **Founder intro (60s):** [Watch on Google Drive](https://drive.google.com/file/d/1Y96Uv4UVBe_TFc2uoEU1tSi-ri3Pv4II/view)
- **Product demo:** [Watch on Google Drive](https://drive.google.com/file/d/1Kmcg-FxzSuB2hdeC-7TkMJY2qXriI3vA/view)

## What is DeepStream?

Everyone now carries high-density, deeply contextual conversations inside ChatGPT and Claude — but that context is trapped in a silo. When you finally need a *human* who has solved your exact problem, you have to throw all that context away and start over with a vague forum post.

DeepStream fixes the last mile:

- **Semantic drift bottles** — your unresolved question (with its context) becomes an "intent capsule" that is vector-matched to people who can actually answer it, instead of being broadcast into a feed.
- **Micro-consulting, not gig work** — solving one concrete problem earns a small tip ("coffee money"), powered by Stripe.
- **Agent-native by design** — capsules are built to plug into the MCP ecosystem, so your AI assistant can carry your intent into the network for you.

## The story

We are two young founders who walked away from comfortable big-tech careers to chase one belief: the next social entry point is not a stronger agent — it's the room *between* agents, where two AIs shake hands on behalf of their humans. No shortcuts, no safety net — just a small team shipping every week, with our first real users in Vietnam.

## Tech stack

| Layer | Tech |
|---|---|
| Client (this repo) | Flutter / Dart, unified entrypoint for iOS & Android |
| Matching | Vector search (Milvus) + CLIP multimodal embeddings |
| Payments | Stripe (deferred payout — no card needed until $10 earned) |
| QA | Custom DSL-driven E2E automation + LLM auto-review workflow |

## Repository structure

```
lib/
├── features/        # auth, chat, home, orders, payment, seller, profile, ...
├── main_unified.dart  # single unified entrypoint
scripts/             # one-command local run / log / stop scripts
docs/                # developer docs
```

## Quick start (development)

Prerequisites: Flutter SDK, Xcode + iOS Simulator, `tmux`.

```bash
cp .env.local-debug.example .env.local-debug
flutter pub get
./scripts/run-ios-unified-local.sh   # run
./scripts/tail-ios-unified-local.sh  # tail logs
./scripts/stop-ios-unified-local.sh  # stop
```

Full development guide (branching model, log paths, script overrides): [docs/DEVELOPMENT.zh-CN.md](docs/DEVELOPMENT.zh-CN.md) *(Chinese)*.

## Status & roadmap

- ✅ iOS client with chat, payments (Stripe), orders, seller flows
- ✅ DSL-based full-regression E2E test harness
- ✅ First user cohort in Vietnam
- 🔜 Open-source MCP plugin so any Claude/ChatGPT user can join the network
- 🔜 Expansion to Thailand & Japan

## License

Source-available for reading and reference. All rights reserved by the DeepStream team; a formal open-source license for the upcoming MCP plugin will be announced in its own repository.

# Applicability screening

Use the app's features, users, business model, data, and markets to decide which requirement
areas to research. A row is a prompt to investigate in each selected market — not a conclusion
that a law applies. Named laws are well-known examples to check, never a substitute for
verifying the current text (see `official-sources.md`).

## Triggers → areas to research → typical work

| Trigger | Research in each market | Typical app / backend work |
|---|---|---|
| Any personal data (accounts, analytics, crash reports, device identifiers, support email) | Data protection law (e.g. EU GDPR, UK GDPR, India DPDP Act 2023, Brazil LGPD, Canada PIPEDA, US state privacy laws such as California CCPA as amended by CPRA): notice, lawful basis or consent, user rights, retention, breach handling, processor terms | Privacy policy and in-app links, data inventory, consent where required, access and deletion flows, processor list, retention jobs |
| Account creation | Apple's in-app account deletion requirement; Google Play's account deletion requirement (in-app and a web link) | Discoverable in-app deletion with confirmation, backend deletion, local data wipe, web deletion page |
| Children, teens, or a mixed audience that may include minors | Children's privacy laws (e.g. US COPPA), age thresholds per market, parental consent, age-appropriate design codes; Apple Kids category rules; Google Play Families policy | Neutral age gate, verifiable parental consent where required, no behavioural ads, SDK restrictions, data minimisation |
| Payments for digital goods or subscriptions | Store billing rules (Apple In-App Purchase, Google Play Billing) and any market-specific alternative-billing programmes; consumer law on price disclosure, auto-renewal, cancellation, refunds | Clear paywall terms, restore purchases, manage-subscription link, server-side receipt validation |
| Payments for physical goods or services | Payment provider rules, PCI DSS scope, consumer and tax rules | Provider-hosted card entry (never handle card data), receipts, refund flow |
| Advertising or cross-app tracking | Apple App Tracking Transparency and privacy labels; Google advertising ID declaration; consent rules for identifiers and ads in some markets; ads to minors | Consent flow before ad SDK initialisation, SDK configuration, declarations |
| Location | Platform permission policies (Google's background location declaration, Apple purpose strings); precise location as sensitive data in some laws | Foreground-only by default, rationale screen, coarse location where enough, retention limits |
| Camera, photos, microphone, contacts | Purpose strings, Google Play photo and video permissions policy, contacts upload sensitivity | System pickers instead of broad permissions, minimal scopes, purpose text |
| Health or wellness data | Health-data and sector rules (e.g. HIPAA only for covered entities and business associates — determine), Apple HealthKit rules, Google Play health apps policy and Health Connect, medical-device rules if the app diagnoses or treats | No medical claims unless regulated, explicit consent, encryption, separate storage |
| Financial data, lending, investing, crypto | Financial regulator licensing, Google Play financial services policy, Apple guidelines on financial and crypto apps | Licence evidence, disclosures, regional availability limits |
| AI features (generative content, chat, automated decisions) | AI-specific transparency rules where they exist (e.g. EU AI Act), store policies on AI-generated content, consent for processing user content by AI providers | AI disclosure labels, report-content mechanism, provider data-use terms, opt-outs |
| User-generated content, messaging, social | Store requirements for reporting, blocking, and moderation; online-safety laws in some markets | Report and block, moderation queue, terms of use, abuse contact |
| Accessibility | Accessibility laws that cover apps or services in some markets (e.g. the EU European Accessibility Act for in-scope services); WCAG as the technical baseline | WCAG 2.2 AA target: labels, contrast, text scaling, focus order, captions |
| Cross-border transfers or data residency | Transfer mechanisms (e.g. GDPR adequacy or standard contractual clauses), localisation rules in some markets | Hosting region decision, processor locations, transfer records |
| Marketing messages and notifications | Consent rules for email, SMS, and push marketing; store notification policies | Separate marketing consent, unsubscribe, no promotional pushes without opt-in |
| Education or school use | Student-data rules (school context) | Needs Review — escalate early |
| All apps | Store review guidelines, metadata accuracy, security baseline (OWASP MASVS — a security practice, not law) | Accurate listing, secure defaults, release gate |

## Screening questions (one grouped round)

1. Which countries or regions at launch, and which within a year?
2. Can anyone under 18 use the app? Under 13 (or the local threshold)?
3. Which of these does the app do: accounts, payments or subscriptions, ads, location, camera or
   photos, microphone, contacts, health, finance, AI, user content or messaging, analytics or
   crash reporting, marketing notifications?
4. Who processes data: backend host and region, auth provider, analytics, crash reporting,
   payments, AI provider?
5. Is the app aimed at a regulated sector (health, finance, education)?

## Output of the screening

For each market: the requirement areas that apply (and why), the ones that do not (and why), and
the ones that depend on a decision (Conditional). Carry each into `country-matrix.md` as rows
to be verified.

# Official sources and verification

## Verification protocol

1. Reach the primary source with web search and fetch tools, or use sources the user provides.
   Prefer legislation text, regulator guidance, and the platform's own policy pages. Secondary
   sources (law-firm notes, blogs) may help locate a primary source but are never the citation.
2. Record, for each requirement: the exact URL, the page or instrument title, the section or
   article, the effective date or transition period as the source states it, and the date you
   checked it.
3. If the official source cannot be reached, is ambiguous, or conflicts with another official
   source, set the status to **Needs Review** and open an issue in `open-issues.md`.
4. Re-verify at every reassessment and before every release. Store policies change often; a
   checked date older than the current release cycle is stale.
5. Summarise in your own words. Do not paste long passages from legal or policy texts.
6. If the user has legal counsel, their written advice overrides your research for that item;
   record it as the source.

## Starting points

Confirm each URL resolves when you use it, then navigate to the specific page and cite that page.

### Platforms

| Source | URL |
|---|---|
| Apple App Store Review Guidelines | https://developer.apple.com/app-store/review/guidelines/ |
| Apple App Privacy details (privacy labels) | https://developer.apple.com/app-store/app-privacy-details/ |
| Apple privacy manifest files | https://developer.apple.com/documentation/bundleresources/privacy-manifest-files |
| Apple account deletion guidance | https://developer.apple.com/support/offering-account-deletion-in-your-app/ |
| Apple Human Interface Guidelines | https://developer.apple.com/design/human-interface-guidelines/ |
| Google Play Developer Program Policies (Policy Center) | https://play.google.com/about/developer-content-policy/ |
| Google Play Console Help (Data safety, account deletion, permissions, Families) | https://support.google.com/googleplay/android-developer/ |
| Google Play target API level requirements | https://developer.android.com/google/play/requirements/target-sdk |

### Regulators and legislation (examples — add the authority for every selected market)

| Market | Starting points |
|---|---|
| European Union | EUR-Lex (legislation) https://eur-lex.europa.eu · European Data Protection Board https://www.edpb.europa.eu · the national data protection authority of each member state |
| United Kingdom | Information Commissioner's Office https://ico.org.uk · legislation https://www.legislation.gov.uk |
| India | Ministry of Electronics and IT https://www.meity.gov.in · India Code (legislation) https://www.indiacode.nic.in · Reserve Bank of India (payments) https://www.rbi.org.in |
| United States (federal) | Federal Trade Commission https://www.ftc.gov · HHS (HIPAA) https://www.hhs.gov/hipaa · ADA https://www.ada.gov |
| United States (states) | California Privacy Protection Agency https://cppa.ca.gov · California Attorney General https://oag.ca.gov/privacy · each state legislature for other state privacy laws |
| Canada | Office of the Privacy Commissioner https://www.priv.gc.ca · Québec Commission d'accès à l'information https://www.cai.gouv.qc.ca |
| Brazil | Autoridade Nacional de Proteção de Dados https://www.gov.br/anpd |
| Australia | Office of the Australian Information Commissioner https://www.oaic.gov.au |
| Singapore | Personal Data Protection Commission https://www.pdpc.gov.sg |
| Japan | Personal Information Protection Commission https://www.ppc.go.jp |
| Any other market | The national data protection authority and official legislation portal, found on the government's own domain |

### Payments and security standards

| Source | URL |
|---|---|
| PCI Security Standards Council | https://www.pcisecuritystandards.org |
| OWASP Mobile Application Security (MASVS / MASTG) | https://mas.owasp.org |

## Recording a requirement

```
| CM-007 | European Union | Data protection | GDPR Art. 17 (right to erasure) | Legal obligation |
  https://eur-lex.europa.eu/... (checked 2026-10-28) | Applies — accounts hold personal data
  of EU users | In force (per source) | In-app deletion flow | Backend erasure job + processor
  deletion | Integration test: delete account → data gone; backend log evidence | Confirmed |
  TASK-12 |
```

The row above shows the shape only; verify every element before writing a real row.

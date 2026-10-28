# App flow — <Project name>

Status: Draft · Approved (Gate 2, <YYYY-MM-DD>)

## Flow

```mermaid
flowchart TD
  Launch([App launch]) --> Session{Valid session?}
  Session -- no --> S01[S-01 <Welcome>]
  Session -- yes --> S10[S-10 <Home>]
  S01 --> S02[S-02 <Sign in>]
  S02 --> S10
  S10 --> S20[S-20 <Feature screen>]
  S20 -- success --> Done([<Success state>])
  S20 -- failure --> Err([<Error state + recovery>])
```

## Screen inventory

| ID | Screen | Purpose | Entry points | Exits | Actions | State owner | Repository / API | States | Auth | Accessibility | Platform notes | Compliance |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S-01 | <name> | <purpose> | <routes, links> | <destinations> | <actions → outcomes> | <provider / bloc> | <methods / endpoints> | loading · empty · error · offline · success | <none / signed in / role> | <focus, labels, announcements> | <iPad, back behaviour> | <CM rows> |

## Edge flows

| Situation | Behaviour |
|---|---|
| Deep link to a protected screen while signed out | <sign in, then continue to the target> |
| Session expires mid-flow | <preserve input, re-authenticate, resume> |
| Offline at launch | <cached content + notice / first-run message> |
| Permission denied / permanently denied | <explanation, degraded mode, path to Settings> |
| Account deletion | <confirm, delete, sign out, land on Welcome> |
| Update required | <blocking screen with store link> |

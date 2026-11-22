---
name: facebook-business-sdk
description: How to use and work on the Facebook Business SDK for Python (facebook_business) in this repo — initializing the API, reading/creating campaigns, ad sets, ads and creatives, pulling Insights reports, batch and async requests, Pages, Conversions API, and running the unit tests. Use when writing code that calls Meta's Marketing/Graph API through this SDK, when the user asks how to use it (in any language, e.g. "استعمال"), or when editing files under facebook_business/.
---

# Facebook Business SDK (Python)

Package: `facebook_business` (version in `setup.py`, Graph API version in
`facebook_business/apiconfig.py`, currently `v27.0`).

## Setup

```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

FacebookAdsApi.init(app_id, app_secret, access_token)  # also: api_version=, timeout=, debug=
account = AdAccount('act_<AD_ACCOUNT_ID>')
```

- Credentials: copy `config.json.example` to `config.json` (git-ignored) and load it.
  Never hard-code or commit tokens.
- Tokens need permissions: `ads_read` / `ads_management` for ads,
  `pages_manage_posts` etc. for Pages.

## Object model (CRUD)

Every Graph object is a class in `facebook_business/adobjects/` (auto-generated —
do not hand-edit those files; helpers live in `adobjects/helpers/`).

| Operation | Method |
|---|---|
| Read node | `Campaign(id).api_get(fields=[...])` |
| Update | `obj.api_update(params={...})` |
| Delete | `obj.api_delete()` |
| Read edge | `account.get_campaigns(fields=[...], params={...})` |
| Create child | `account.create_campaign(params={...})` |

Field/enum names are class attributes, e.g. `Campaign.Field.name`,
`Campaign.Status.paused`, `AdSet.BillingEvent.impressions`.
Edge results are a lazy, auto-paginating `Cursor` — iterate it.

## Common recipes

Create a paused campaign:
```python
from facebook_business.adobjects.campaign import Campaign
campaign = account.create_campaign(params={
    Campaign.Field.name: 'My campaign',
    Campaign.Field.objective: 'OUTCOME_TRAFFIC',
    Campaign.Field.status: Campaign.Status.paused,
    Campaign.Field.special_ad_categories: [],
})
```

Insights report:
```python
from facebook_business.adobjects.adsinsights import AdsInsights
rows = account.get_insights(
    fields=[AdsInsights.Field.campaign_name, AdsInsights.Field.spend,
            AdsInsights.Field.impressions, AdsInsights.Field.clicks],
    params={'level': 'campaign', 'date_preset': 'last_7d'},
)
```
For large reports pass `is_async=True` and poll the returned job.

Batch requests: see `examples/batch_create.py`, `examples/batch_pause.py`.
Async (aiohttp): `examples/async.py`.
Conversions API (server-side events): `facebook_business/adobjects/serverside/`,
example `examples/ServerSideApi.py`.
Pages: `examples/PageFeedPost.py`, `examples/PagePostsEdge.py`.

`examples/` has ~150 runnable scripts named after the endpoint
(`AdAccountCampaignsEdge.py`, `AdsInsightsEdge*.py`, …) — grep there first.

## Errors

API errors raise `facebook_business.exceptions.FacebookRequestError`;
inspect `e.api_error_code()`, `e.api_error_message()`, `e.http_status()`.

## Tests

```bash
python3 -m facebook_business.test.unit                     # unit tests (offline)
python3 -m unittest facebook_business.test.unit.EdgeIteratorTestCase
```
`integration_test_runner` mocks HTTP; it does not need real credentials.
Dependencies are installed by `.claude/hooks/session-start.sh` in cloud sessions.

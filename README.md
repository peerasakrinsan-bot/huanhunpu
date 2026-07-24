# huanhunpu

## Deployment

Pushing to the `main` branch runs the GitHub Actions workflow in `.github/workflows/deploy-vercel.yml`.
The workflow exports the Godot 4.4 project with the `Web` export preset and deploys the generated HTML5 files from `build/web` to Vercel.

Configure these GitHub Actions secrets before relying on production deploys:

- `VERCEL_TOKEN`: a Vercel token with access to the target project.
- `VERCEL_ORG_ID`: the Vercel team or user ID for the target project.
- `VERCEL_PROJECT_ID`: the Vercel project ID that should receive the deployment.

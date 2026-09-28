//! Generate a basic application configuration.

use std::io::Write;

use anyhow::Context;
use clap::{ArgGroup, Args};

use crate::settings::Settings;

/// Selects the defaults used in a generated configuration.
#[derive(Clone, Debug, Eq, PartialEq, Args)]
#[command(group(ArgGroup::new("mode").required(true).multiple(false).args(["production", "development"])))]
pub struct GenerateConfigArgs {
    /// Use production defaults; edit the URLs for your deployment.
    #[arg(long)]
    pub production: bool,
    /// Use local development defaults, including validation bypass.
    #[arg(long = "no-production", visible_alias = "development")]
    pub development: bool,
}

/// Prints a configuration using the selected defaults.
pub(crate) fn run(args: &GenerateConfigArgs) -> anyhow::Result<()> {
    let mut settings = Settings::default();
    if !args.production {
        // The generated config is used by the Compose development stack.
        settings.database.url =
            serde_saphyr::from_str("postgresql://lfsplanet:lfsplanet@postgres:5432/lfsplanet")
                .context("failed to construct the development database URL")?;
        // Browsers reach both the frontend and auth routes through Vite over HTTP.
        settings.web.public_base_url = serde_saphyr::from_str("http://localhost:5173")
            .context("failed to construct the development public URL")?;
        settings.web.cookie_secure = false;
        settings.hotlaps.allow_test_validation = true;
    }
    let mut options = serde_saphyr::SerializerOptions::default();
    options.prefer_block_scalars = false;
    let yaml = serde_saphyr::to_string_with_options(&settings, options)
        .context("failed to serialize default settings as YAML")?;
    std::io::stdout()
        .write_all(yaml.as_bytes())
        .context("failed to write default settings to standard output")?;
    Ok(())
}

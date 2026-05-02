$ErrorActionPreference = 'Stop'
$VaultRoot = 'C:\Users\deniz\Documents\miraculix'
$Git = 'C:\Program Files\Git\cmd\git.exe'

Set-Location -LiteralPath $VaultRoot

$paths = @(
    '01-projekte/pulsepeptides/firmenstruktur.md',
    '01-projekte/pulsepeptides/pulsepeptides.md',
    '01-projekte/pulsepeptides/coo-automations.md',
    '01-projekte/pulsepeptides/custom-orders/prostamax.md',
    '01-projekte/pulsepeptides/knowledge-base/bulk-pricing.md',
    '01-projekte/pulsepeptides/knowledge-base/team-koordination.md',
    '01-projekte/pulsepeptides/logs/2026-04-17-coo-rolle-transition-start.md',
    '01-projekte/pulsepeptides/logs/2026-04-28-lager-besuch-kalani.md',
    '01-projekte/pulsepeptides/logs/2026-04-29-slack-invoice-verification-7347.md',
    '02-wissen/vault-schreibkonventionen.md',
    '02-wissen/vault-schreibregeln.md',
    '03-kontakte/marlon-wettstein.md',
    '04-tagebuch/2026/05/2026-05-02.md',
    '_cleanup-phase-3-report.md',
    '_claude/scripts/commit-message-2026-05-02.txt',
    '_claude/scripts/rename-wikilinks-2026-05-02.ps1'
)

# add slack files individually (path with umlaut)
$slackDir = '01-projekte/persönlich/kommunikation-referenzen/slack'
$slackFiles = @(
    '2026-04-09_christian_tuomo-test-batch.md',
    '2026-04-11_christian_kpv-stock-kommunikation.md',
    '2026-04-16_christian_telefonnummer-austausch-dm.md',
    '2026-04-20_christian-kalani_us-market-shipments.md',
    '2026-04-20_christian_affiliate-1k-follower-cap.md',
    '2026-04-20_christian_prostamax-custom-order.md',
    '2026-04-20_christian_reta-lab-test.md',
    '2026-04-23_christian_pepspan-bulk-pricing.md',
    '2026-04-24_christian_affiliate-free-samples.md',
    '2026-04-27_christian_credit-card-processor.md'
)
foreach ($f in $slackFiles) {
    $paths += "$slackDir/$f"
}

foreach ($p in $paths) {
    Write-Host "Adding: $p"
    & $Git add -- $p
}

Write-Host ""
Write-Host "Status after add:"
& $Git status --short

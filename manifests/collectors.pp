# Class: scollector::collectors
# ===========================
#
# this class is applied when $use_hiera is true
#
class scollector::collectors {

  $custom_collectors = hiera_hash('scollector::custom_collector', {})

  create_resources(scollector::collector, $custom_collectors)

  Scollector::Collector<| |>
}

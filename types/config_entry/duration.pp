# Duration as Consul reads it, for example `5s`, `500ms` or `1m30s`.
type Consul::Config_entry::Duration = Pattern[/\A(\d+(\.\d+)?(ns|us|µs|ms|s|m|h))+\z/]

include_recipe "git"
include_recipe "nodejs"
include_recipe "runit"

git node["statsd"]["dir"] do
  repository node["statsd"]["repository"]
  action :sync
  notifies :restart, "runit_service[statsd]"
end

directory node["statsd"]["conf_dir"] do
  action :create
end

template "#{node["statsd"]["conf_dir"]}/config.js" do
  mode "0644"
  source "config.js.erb"
  variables(
    :address          => node["statsd"]["address"],
    :port             => node["statsd"]["port"],
    :flush_interval   => node["statsd"]["flush_interval"],
    :graphite_port    => node["statsd"]["graphite_port"],
    :graphite_host    => node["statsd"]["graphite_host"],
    :delete_gauges    => node["statsd"]["delete_gauges"],
    :delete_timers    => node["statsd"]["delete_timers"],
    :legacy_namespace => node["statsd"]["graphite"]["legacy_namespace"],
    :global_prefix    => node["statsd"]["graphite"]["global_prefix"],
    :prefix_counter   => node["statsd"]["graphite"]["prefix_counter"],
    :prefix_timer     => node["statsd"]["graphite"]["prefix_timer"],
    :prefix_gauge     => node["statsd"]["graphite"]["prefix_gauge"],
    :prefix_set       => node["statsd"]["graphite"]["prefix_set"]
  )
  notifies :restart, "runit_service[statsd]"
end

user node["statsd"]["username"] do
  system true
  shell "/bin/false"
end

runit_service "statsd" do
  action [:enable, :start]
  default_logger true
  options ({
    :user => node['statsd']['username'],
    :statsd_dir => node['statsd']['dir'],
    :conf_dir => node['statsd']['conf_dir']
  })
end

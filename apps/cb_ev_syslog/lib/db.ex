use Amnesia

defdatabase CbEvSyslog.DB do
  deftable Sensor, [:id,
                    :status,
                    :os_environment_display_string,
                    :computer_name,
                    :computer_dns_name,
                    :computer_sid,
                    :network_adapters,
                    :boot_id,
                    :group_id], type: :set
end

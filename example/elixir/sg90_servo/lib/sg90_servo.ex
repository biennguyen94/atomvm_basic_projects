defmodule Sg90Servo do


  @duty_0_deg 205
  @duty_90_deg 600
  @duty_180_deg 1100

  @high_speed_timer 0
  @servo_pin 13

  def start do
    ledc_timer = [
      {:duty_resolution, 13},
      {:freq_hz, 50},
      {:speed_mode, LEDC.high_speed_mode()},
      {:timer_num, @high_speed_timer}
    ]

    :ok = LEDC.timer_config(ledc_timer)

    servo_channel = [
      {:channel, 0},
      {:duty, @duty_90_deg},
      {:gpio_num, @servo_pin},
      {:speed_mode, LEDC.high_speed_mode()},
      {:hpoint, 0},
      {:timer_sel, @high_speed_timer}
    ]

    :ok = LEDC.channel_config(servo_channel)
    loop(servo_channel)
  end

  def loop(servo_channel) do
    :io.format(~c"Quay sang 90 do...~n")
    do_set_duty(servo_channel, @duty_90_deg)
    Process.sleep(2000)

    :io.format(~c"Quay sang 0 do...~n")
    do_set_duty(servo_channel, @duty_0_deg)
    Process.sleep(2000)

    :io.format(~c"Quay sang 180 do...~n")
    do_set_duty(servo_channel, @duty_180_deg)
    Process.sleep(2000)

    loop(servo_channel)
  end

  defp do_set_duty(channel_config, target_duty) do
    speed_mode = :proplists.get_value(:speed_mode, channel_config)
    channel = :proplists.get_value(:channel, channel_config)
    :ok = LEDC.set_duty(speed_mode, channel, target_duty)
    :ok = LEDC.update_duty(speed_mode, channel)
  end
end

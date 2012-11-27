require "vmc/cli/app/base"

module VMC::App
  class Instances < Base
    desc "List an app's instances"
    group :apps, :info, :hidden => true
    input :apps, :argument => :splat, :singular => :app,
      :desc => "Applications whose instances to list",
      :from_given => by_name("app")
    def instances
      apps = input[:apps]
      fail "No applications given." if apps.empty?

      spaced(apps) do |app|
        instances =
          with_progress("Getting instances for #{c(app.name, :name)}") do
            app.instances
          end

        spaced(instances) do |i|
          if quiet?
            line i.id
          else
            display_instance(i)
          end
        end
      end
    end

    def display_instance(i)
      start_line "instance #{c("\##{i.id}", :instance)}: "
      puts "#{b(c(i.state.downcase, state_color(i.state)))} "

      indented do
        if s = i.since
          line "started: #{c(s.strftime("%F %r"), :neutral)}"
        end

        if d = i.debugger
          line "debugger: port #{b(d[:port])} at #{b(d[:ip])}"
        end

        if c = i.console
          line "console: port #{b(c[:port])} at #{b(c[:ip])}"
        end
      end
    end
  end
end

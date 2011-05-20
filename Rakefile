desc "Run Cukes and Specs"
task :default => ["spec", "cukes"]

task :cukes do
  sh "cucumber"
end

task :spec do
  sh "rspec spec"
end

task :focus do
  sh "rspec -t focus spec"
end

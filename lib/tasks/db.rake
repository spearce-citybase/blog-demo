task :seed => [:environment] do
  SeedService.seed_all
end
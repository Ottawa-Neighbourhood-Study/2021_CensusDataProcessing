wide = read_csv("outputs/pq outputs/processed/pq_census_data_hh_var.csv")

long = pivot_longer(wide, 3:(ncol(wide)-1))
colnames(wide)
colnames(wide)[1]="test"

write.csv(long, file="outputs/pq outputs/processed/pq_census_data_hh_var_long.csv")
import pandas as pd
import sys

def main(stock_file, earning_file, output_file):
    # Read the CSV files
    stock_df = pd.read_csv(stock_file)
    earning_df = pd.read_csv(earning_file)

    # Merge the two dataframes on the 'symbol' column
    merged_df = pd.merge(stock_df, earning_df, on='symbol', how='inner')

    # Add the new column with value equal to count * earning and name it 'annual'
    merged_df['annual'] = (merged_df['count'] * merged_df['earning']).astype(int)

    # Add the 'rate' column
    merged_df['rate'] = (merged_df['earning'] / merged_df['price']) * 100

    # Format the 'rate' column to 2 decimal places
    merged_df['rate'] = merged_df['rate'].map(lambda x: f"{x:.2f}%")

    # Add the 'buy' column
    merged_df['buy'] = merged_df['rate'].apply(lambda x: 'Y' if float(x.strip('%')) > 5 else 'N')

    # Reorder the columns to place 'annual' before 'rate'
    cols = list(merged_df.columns)
    rate_index = cols.index('rate')
    cols.insert(rate_index, cols.pop(cols.index('annual')))
    merged_df = merged_df[cols]

    # Write the merged dataframe to a new CSV file
    merged_df.to_csv(output_file, index=False)

    # Print the merged dataframe
    print(merged_df)

    # Calculate the sum of the 'annual' column
    annual_sum = merged_df['annual'].sum()
    print(f"The sum of the 'annual' column is: {annual_sum}")

    print(f"CSV files have been successfully joined and saved to '{output_file}'")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <stock_file> <earning_file> <output_file>")
    else:
        stock_file = sys.argv[1]
        earning_file = sys.argv[2]
        output_file = sys.argv[3]
        main(stock_file, earning_file, output_file)

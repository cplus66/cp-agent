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

    # Write the merged dataframe to a new CSV file
    merged_df.to_csv(output_file, index=False)

    # Remove the 'date' column before printing
    merged_df = merged_df.drop(columns=['date'])

    # Print the merged dataframe
    print(merged_df)

    # Calculate the sum of the 'annual' column
    annual_sum = merged_df['annual'].sum()
    print(f"Summary: Total value of all earning is {annual_sum} TWD")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <stock_file> <earning_file> <output_file>")
    else:
        stock_file = sys.argv[1]
        earning_file = sys.argv[2]
        output_file = sys.argv[3]
        main(stock_file, earning_file, output_file)

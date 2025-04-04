import pandas as pd
import argparse

def calculate_interest(input_file, output_file, summary_file):
    
    # Read the input CSV file using pandas
    df = pd.read_csv(input_file)
    
    # Calculate the total value of the 'ntd' column
    total_ntd = df[df['price'] != 'Invalid Data']['price'].sum()

    # Save the updated DataFrame to the output CSV file
    df.to_csv(output_file, index=False)
    
    # Print the content of the DataFrame after removing the 'expire' column
    print(df)
    print(f"Summary: Total value of the US cash interest is {total_ntd} TWD")
    
    # Append the total values to the summary CSV file
    with open(summary_file, 'a', newline='') as summary:
        writer = pd.DataFrame([['cash_tw', total_ntd]], columns=['name', 'value'])
        writer.to_csv(summary, header=False, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    parser.add_argument('-s', '--summary', required=True, help='Summary CSV file to append the total value')
    args = parser.parse_args()
    
    calculate_interest(args.file, args.output, args.summary)

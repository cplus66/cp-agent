import pandas as pd
import argparse

def calculate_interest(input_file, output_file):
    
    # Read the input CSV file using pandas
    df = pd.read_csv(input_file)
    
    # Calculate the total value of the 'ntd' column
    total_ntd = df[df['value'] != 'Invalid Data']['value'].sum()

    # Save the updated DataFrame to the output CSV file
    df.to_csv(output_file, index=False)
    
    # Print the content of the DataFrame after removing the 'expire' column
    print(df)
    print(f"Summary: Total value is {total_ntd} TWD")
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    args = parser.parse_args()
    
    calculate_interest(args.file, args.output)

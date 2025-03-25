import pandas as pd
import argparse

def read_usd_to_twd_conversion(file_path):
    with open(file_path, 'r') as file:
        conversion_rate = float(file.read().strip())
    return conversion_rate

def calculate_interest(input_file, output_file, conversion_file):
    conversion_rate = read_usd_to_twd_conversion(conversion_file)
    
    # Read the input CSV file using pandas
    df = pd.read_csv(input_file)
    
    # Calculate interest
    df['interest'] = df.apply(lambda row: float(row['unit']) * float(row['rate']) if pd.notnull(row['unit']) and pd.notnull(row['rate']) else 'Invalid Data', axis=1)
    
    # Calculate NTD
    df['ntd'] = df.apply(lambda row: int(row['interest'] * conversion_rate) if row['interest'] != 'Invalid Data' else 'Invalid Data', axis=1)
    
    # Print the content of the DataFrame before saving
    print("DataFrame content before saving:")
    print(df)
    
    # Calculate and print the total value of the 'ntd' column
    total_ntd = df[df['ntd'] != 'Invalid Data']['ntd'].sum()
    print(f"\nTotal value of the 'ntd' column: {total_ntd}")
    
    # Save the updated DataFrame to the output CSV file
    df.to_csv(output_file, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    parser.add_argument('-c', '--conversion', required=True, help='USD to TWD conversion rate file')
    args = parser.parse_args()
    
    calculate_interest(args.file, args.output, args.conversion)

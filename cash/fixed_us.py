import pandas as pd
import argparse

def read_usd_to_twd_conversion(file_path):
    with open(file_path, 'r') as file:
        conversion_rate = float(file.read().strip())
    return conversion_rate

def calculate_interest(input_file, output_file, conversion_file, summary_file):
    conversion_rate = read_usd_to_twd_conversion(conversion_file)
    
    # Read the input CSV file using pandas
    df = pd.read_csv(input_file)
    
    # Calculate interest
    df['interest'] = df.apply(lambda row: float(row['price']) * float(row['rate']) if pd.notnull(row['price']) and pd.notnull(row['rate']) else 'Invalid Data', axis=1)
    
    # Calculate NTD
    df['ntd'] = df.apply(lambda row: int(row['interest'] * conversion_rate) if row['interest'] != 'Invalid Data' else 'Invalid Data', axis=1)
    
    # Save the updated DataFrame to the output CSV file
    df.to_csv(output_file, index=False)
    
    # Print the content of the DataFrame after removing the 'expire' column
    print(df)

    # Calculate the total value of the 'ntd' column
    total_ntd = df[df['ntd'] != 'Invalid Data']['ntd'].sum()
    print(f"Summary: Total value of the US cash interest is {total_ntd} TWD")
    
    # Append the total values to the summary CSV file
    with open(summary_file, 'a', newline='') as summary:
        writer = pd.DataFrame([['total_ntd', total_ntd]], columns=['name', 'value'])
        writer.to_csv(summary, header=False, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    parser.add_argument('-c', '--conversion', required=True, help='USD to TWD conversion rate file')
    parser.add_argument('-s', '--summary', required=True, help='Summary CSV file to append the total value')
    args = parser.parse_args()
    
    calculate_interest(args.file, args.output, args.conversion, args.summary)

import pandas as pd
import argparse

def read_usd_to_twd_conversion(file_path):
    with open(file_path, 'r') as file:
        conversion_rate = float(file.read().strip())
    return conversion_rate

def calculate_bond(input_file, output_file, conversion_file, summary_file):
    conversion_rate = read_usd_to_twd_conversion(conversion_file)
    
    # Read the input CSV file using pandas
    df = pd.read_csv(input_file)
    
    # Calculate curr-ntd-value
    df['curr-ntd-value'] = df.apply(lambda row: int(float(row['unit']) / 100 * float(row['ref-price']) * conversion_rate) if pd.notnull(row['unit']) and pd.notnull(row['ref-price']) else 'Invalid Data', axis=1)
    
    # Save the updated DataFrame to the output CSV file
    df.to_csv(output_file, index=False)
    
    # Remove the 'expire' column if it exists
    if 'expire' in df.columns:
        df.drop(columns=['expire'], inplace=True)
    
    # Print the content of the DataFrame after removing the 'expire' column
    print(df)

    # Calculate the total value of the 'curr-ntd-value' column
    total_curr_ntd_value = df[df['curr-ntd-value'] != 'Invalid Data']['curr-ntd-value'].sum()
    print(f"Summary: Total value of the bond is {total_curr_ntd_value} TWD")
    
    # Append the total values to the summary CSV file
    with open(summary_file, 'a', newline='') as summary:
        writer = pd.DataFrame([['bond', total_curr_ntd_value]], columns=['name', 'value'])
        writer.to_csv(summary, header=False, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    parser.add_argument('-c', '--conversion', required=True, help='USD to TWD conversion rate file')
    parser.add_argument('-s', '--summary', required=True, help='Summary CSV file to append the total value')
    args = parser.parse_args()
    
    calculate_bond(args.file, args.output, args.conversion, args.summary)

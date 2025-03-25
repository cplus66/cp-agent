import csv
import argparse

def read_usd_to_twd_conversion(file_path):
    with open(file_path, 'r') as file:
        conversion_rate = float(file.read().strip())
    return conversion_rate

def calculate_interest(input_file, output_file, conversion_file):
    conversion_rate = read_usd_to_twd_conversion(conversion_file)
    
    with open(input_file, mode='r') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames + ['interest', 'ntd']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for row in reader:
            unit = row['unit']
            rate = row['rate']
            
            if unit and rate:  # Check if unit and rate are not empty or None
                try:
                    unit = float(unit)
                    rate = float(rate)
                    interest = unit * rate
                    ntd = int(interest * conversion_rate)
                except ValueError:
                    interest = 'Invalid Data'
                    ntd = 'Invalid Data'
            else:
                interest = 'Invalid Data'
                ntd = 'Invalid Data'
            
            row['interest'] = interest
            row['ntd'] = ntd
            writer.writerow(row)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Calculate interest and save to output file.')
    parser.add_argument('-f', '--file', required=True, help='Input CSV file')
    parser.add_argument('-o', '--output', required=True, help='Output CSV file')
    parser.add_argument('-c', '--conversion', required=True, help='USD to TWD conversion rate file')
    args = parser.parse_args()
    
    calculate_interest(args.file, args.output, args.conversion)

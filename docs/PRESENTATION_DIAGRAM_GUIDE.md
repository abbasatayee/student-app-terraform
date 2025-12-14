# Complete Step-by-Step: Architecture Diagram for Presentation

## Quick Start (42 Minutes Total)

### 🎯 Goal

Create a professional, presentation-ready architecture diagram showing your complete AWS infrastructure.

### 📋 Tools Needed

- **Draw.io** (https://app.diagrams.net/) - Free, web-based
- **AWS Icons** (included in Draw.io)
- **Time**: ~42 minutes

---

## STEP-BY-STEP INSTRUCTIONS

### STEP 1: Setup Draw.io (2 minutes)

1. **Open Draw.io**

   - Go to: https://app.diagrams.net/
   - Click "Create New Diagram"
   - Choose "Blank Diagram"
   - Click "Create"

2. **Enable AWS Icons**

   - Click "More Shapes" (bottom left)
   - Scroll and check "AWS19" or "AWS18"
   - Click "Apply"

3. **Set Canvas Size**
   - File → Page Setup
   - Width: 1920
   - Height: 1080
   - Click "OK"

---

### STEP 2: Create VPC Structure (5 minutes)

#### 2.1 Draw VPC Container

1. Drag a **large rectangle** from shapes (or use Rectangle tool)
2. **Size**: Cover about 80% of canvas (center it)
3. **Label**: "VPC: 10.0.0.0/16 - Student Web Application"
4. **Color**: Light Blue (#E3F2FD)
5. **Border**: 3px, Dark Blue

#### 2.2 Add Availability Zones

1. Draw **2 vertical lines** inside VPC (dividing it in half)
2. **Left side label**: "Availability Zone 1 (us-east-1a)"
3. **Right side label**: "Availability Zone 2 (us-east-1b)"
4. **Background**: Very light gray (#F5F5F5)

#### 2.3 Create Subnets

**In each AZ, create 2 rectangles:**

**Top Rectangle (Public Subnet):**

- **Color**: Light Green (#C8E6C9)
- **Border**: 2px, Green
- **AZ 1**: Label "Public Subnet 1 (10.0.1.0/24)"
- **AZ 2**: Label "Public Subnet 2 (10.0.2.0/24)"

**Bottom Rectangle (Private Subnet):**

- **Color**: Light Orange (#FFE0B2)
- **Border**: 2px, Orange
- **AZ 1**: Label "Private Subnet 1 (10.0.101.0/24)"
- **AZ 2**: Label "Private Subnet 2 (10.0.102.0/24)"

---

### STEP 3: Add Internet Gateway (2 minutes)

1. **Find AWS Icon**: Search "Internet Gateway" in AWS shapes
2. **Position**: Above VPC, centered
3. **Label**: "Internet Gateway"
4. **Size**: Medium (visible but not too large)
5. **Draw connection line**: From Internet Gateway to VPC (dashed line)

---

### STEP 4: Add Application Load Balancer (3 minutes)

1. **Find AWS Icon**: "Application Load Balancer" from AWS shapes
2. **Position**: Spanning both public subnets (centered horizontally)
3. **Size**: Wide enough to show it's in both AZs
4. **Label**: "Application Load Balancer (ALB)"
5. **Add text box below**:
   - "Protocol: HTTP"
   - "Port: 80"
   - "Cross-Zone: Enabled"
6. **Color**: Light Purple (#E1BEE7)

---

### STEP 5: Add Target Group (2 minutes)

1. **Find AWS Icon**: "Target Group" from AWS shapes
2. **Position**: Below ALB, in public subnet area
3. **Label**: "Target Group"
4. **Add text box**:
   - "Health Check: /"
   - "Interval: 30s"
   - "Healthy Threshold: 2"
5. **Draw connection**: ALB → Target Group (arrow, blue, thick)

---

### STEP 6: Add Auto Scaling Group Container (2 minutes)

1. **Draw a container box** (rectangle with dashed border)
2. **Position**: Spanning both private subnets
3. **Label**: "Auto Scaling Group (ASG)"
4. **Add text box inside**:
   - "Min: 1"
   - "Max: 6"
   - "Desired: 2"
   - "Scaling: CPU-based (80% target)"
5. **Color**: Very light blue (#E8F4F8)

---

### STEP 7: Add EC2 Instances (5 minutes)

1. **Find AWS Icon**: "EC2 Instance" from AWS shapes
2. **Add 2 instances**:
   - **Instance 1**: In Private Subnet 1 (AZ 1)
   - **Instance 2**: In Private Subnet 2 (AZ 2)
3. **Label each**: "EC2 Instance"
4. **Add text boxes for each**:
   - "Type: t3.micro"
   - "OS: Ubuntu 22.04 LTS"
   - "App: Node.js"
   - "Port: 80"
5. **Position**: Inside ASG container
6. **Draw connections**: Target Group → EC2 Instance 1 (arrow)
7. **Draw connections**: Target Group → EC2 Instance 2 (arrow)
8. **Color**: Light Blue (#BBDEFB)

---

### STEP 8: Add RDS Database (5 minutes)

1. **Find AWS Icon**: "RDS MySQL" from AWS shapes
2. **Add 2 database instances**:
   - **Primary**: In Private Subnet 1 (bottom)
   - **Standby**: In Private Subnet 2 (bottom)
3. **Label Primary**: "RDS MySQL Primary"
4. **Label Standby**: "RDS MySQL Standby (Multi-AZ)"
5. **Add text boxes for each**:
   - "Engine: MySQL 8.0"
   - "Instance: db.t3.micro"
   - "Storage: 20 GB"
   - "Port: 3306"
6. **Draw connection**: Primary ↔ Standby (purple arrow, label "Replication")
7. **Draw connections**: EC2 Instance 1 → RDS Primary (green arrow, label "MySQL 3306")
8. **Draw connections**: EC2 Instance 2 → RDS Primary (green arrow, label "MySQL 3306")
9. **Color**: Light Pink (#F8BBD0)

---

### STEP 9: Add Security Groups (5 minutes)

Create **3 separate boxes** outside VPC (right side):

#### 9.1 Load Balancer Security Group

- **Box**: Rectangle
- **Label**: "Load Balancer Security Group"
- **Rules**:
  - "Inbound:"
  - " • HTTP (80) from 0.0.0.0/0"
  - " • HTTPS (443) from 0.0.0.0/0"
  - "Outbound: All traffic"
- **Color**: Light Yellow (#FFF9C4)
- **Draw dashed line**: To ALB

#### 9.2 Web Server Security Group

- **Box**: Rectangle
- **Label**: "Web Server Security Group"
- **Rules**:
  - "Inbound:"
  - " • HTTP (80) from LB Security Group"
  - "Outbound: All traffic"
- **Color**: Light Yellow (#FFF9C4)
- **Draw dashed lines**: To both EC2 instances

#### 9.3 Database Security Group

- **Box**: Rectangle
- **Label**: "Database Security Group"
- **Rules**:
  - "Inbound:"
  - " • MySQL (3306) from Web Security Group"
  - "Outbound: All traffic"
- **Color**: Light Yellow (#FFF9C4)
- **Draw dashed lines**: To both RDS instances

---

### STEP 10: Add IAM and Secrets Manager (3 minutes)

#### 10.1 IAM Role

1. **Find AWS Icon**: "IAM Role" from AWS shapes
2. **Position**: Top right, outside VPC
3. **Label**: "EC2 IAM Role"
4. **Add text box**:
   - "Policies:"
   - " • AmazonSSMManagedInstanceCore"
   - " • SecretsManagerReadWrite"
5. **Draw dashed lines**: To both EC2 instances

#### 10.2 Secrets Manager

1. **Find AWS Icon**: "Secrets Manager" from AWS shapes
2. **Position**: Top left, outside VPC
3. **Label**: "AWS Secrets Manager"
4. **Add text box**:
   - "Secret: Mydbsecret"
   - "Contains: DB Credentials"
5. **Draw dashed line**: To IAM Role (showing access path)

---

### STEP 11: Add Route Table (2 minutes)

1. **Find AWS Icon**: "Route Table" from AWS shapes
2. **Position**: Near public subnets
3. **Label**: "Public Route Table"
4. **Add text box**:
   - "Route:"
   - " 0.0.0.0/0 → Internet Gateway"
5. **Draw connections**: To both public subnets (dashed lines)

---

### STEP 12: Add User Traffic Flow (3 minutes)

Draw **thick blue arrows** showing user request flow:

1. **Internet → Internet Gateway**

   - Label: "HTTP/HTTPS"
   - Arrow: Thick, Blue

2. **Internet Gateway → ALB**

   - Label: "Traffic"
   - Arrow: Thick, Blue

3. **ALB → Target Group**

   - Label: "Load Balance"
   - Arrow: Thick, Blue

4. **Target Group → EC2 Instances**
   - Label: "HTTP (80)"
   - Arrow: Thick, Blue (one to each instance)

---

### STEP 13: Add Title and Metadata (3 minutes)

#### 13.1 Title Box (Top Center)

- **Text**: "Student Web Application"
- **Subtitle**: "AWS Infrastructure Architecture"
- **Font**: Large, Bold
- **Background**: White with border

#### 13.2 Metadata Box (Bottom Left)

- **Title**: "Infrastructure Specifications"
- **Content**:
  - "Region: us-east-1"
  - "Availability: 99.95% (Multi-AZ)"
  - "Scalability: 1-6 instances (Auto Scaling)"
  - "Security: Network isolation, IAM, Encryption"
  - "Backup: 7-day retention"

---

### STEP 14: Add Legend (2 minutes)

Create **Legend box** (Bottom Right):

**Colors:**

- 🟩 Light Green = Public Subnets
- 🟧 Light Orange = Private Subnets
- 🟦 Light Blue = Compute Resources
- 🩷 Light Pink = Database
- 🟨 Light Yellow = Security

**Lines:**

- → Blue (Thick) = User Traffic
- → Green = Database Traffic
- ↔ Purple = Replication
- - - - Dashed = Security/IAM

---

### STEP 15: Final Polish (3 minutes)

1. **Align all components** (use alignment tools)
2. **Consistent spacing** between elements
3. **Check all labels** are readable
4. **Verify all connections** are drawn
5. **Add callouts** for key features:
   - "High Availability" near Multi-AZ
   - "Auto Scaling" near ASG
   - "Secure" near Security Groups

---

## EXPORT FOR PRESENTATION

### Export Options:

1. **PNG (High Resolution)**

   - File → Export as → PNG
   - Resolution: 300 DPI
   - Background: White
   - Use for: PowerPoint, Keynote

2. **PDF**

   - File → Export as → PDF
   - Use for: Documentation, handouts

3. **SVG**
   - File → Export as → SVG
   - Use for: Web, scalable graphics

---

## PRESENTATION SLIDE BREAKDOWN

### Slide 1: Complete Architecture (Overview)

- Show entire diagram
- Highlight: "High Availability, Scalable, Secure"

### Slide 2: Network Layer (Zoom In)

- VPC structure
- Subnets and routing
- Internet Gateway

### Slide 3: Compute & Scaling (Zoom In)

- Auto Scaling Group
- Load Balancer
- EC2 instances
- Scaling metrics

### Slide 4: Database Layer (Zoom In)

- Multi-AZ setup
- Primary and Standby
- Replication
- Backup strategy

### Slide 5: Security Architecture (Zoom In)

- Security groups
- IAM roles
- Secrets Manager
- Network isolation

### Slide 6: Data Flow Animation

- Step-by-step request flow
- Response flow
- Database queries

---

## KEY POINTS TO HIGHLIGHT

1. **High Availability**

   - Multi-AZ deployment
   - Automatic failover
   - 99.95% availability

2. **Scalability**

   - Auto Scaling (1-6 instances)
   - CPU-based scaling
   - Load distribution

3. **Security**

   - Network isolation
   - Security groups
   - IAM roles
   - Encrypted storage

4. **Cost Optimization**
   - Right-sized instances
   - Auto Scaling reduces costs
   - Multi-AZ for production

---

## TIME BREAKDOWN

- Setup: 2 min
- VPC Structure: 5 min
- Internet Gateway: 2 min
- Load Balancer: 3 min
- Target Group: 2 min
- ASG Container: 2 min
- EC2 Instances: 5 min
- RDS Database: 5 min
- Security Groups: 5 min
- IAM & Secrets: 3 min
- Route Table: 2 min
- Traffic Flow: 3 min
- Title & Metadata: 3 min
- Legend: 2 min
- Polish: 3 min

**Total: ~42 minutes**

---

## TIPS FOR BEST RESULTS

1. ✅ Use AWS official icons for professional look
2. ✅ Keep colors consistent (use the color scheme provided)
3. ✅ Label everything clearly
4. ✅ Show data flow with arrows
5. ✅ Group related components
6. ✅ Use callouts for important features
7. ✅ Include metrics and specifications
8. ✅ Test readability at presentation size
9. ✅ Export in multiple formats
10. ✅ Keep a backup copy

---

## FILES CREATED

You now have:

- ✅ `ARCHITECTURE_DIAGRAM.md` - Main guide
- ✅ `ARCHITECTURE_DETAILED.md` - Detailed specifications
- ✅ `DIAGRAM_COMPONENTS.md` - Component checklist
- ✅ `ARCHITECTURE_TEXT_DIAGRAM.txt` - Text representation
- ✅ `architecture.mmd` - Mermaid diagram code
- ✅ `create_diagram_instructions.txt` - Quick reference
- ✅ `PRESENTATION_DIAGRAM_GUIDE.md` - This file

**Start with this file (PRESENTATION_DIAGRAM_GUIDE.md) for step-by-step instructions!**

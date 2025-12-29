# 🏗️ Rawnaq - Integrated Construction & Design ERP System

## 📋 Overview

A comprehensive technical and administrative system designed for small and medium-sized construction and finishing companies. Rawnaq bridges the gap between the design department (hierarchical structure) and the execution department, with a flexible project lifecycle that starts from site inspection to key handover.

## 🚀 Core Features

### 1. Flexible Management Hierarchy (Scalable Hierarchy)

**Role-Based Access Control with Permissions (RBAC + PBAC)**: Flexible system that supports:
- **Multiple Roles per User**: Users can have multiple job titles (e.g., Civil Engineer + Accountant)
- **Auto-Assigned Permissions**: Permissions are automatically assigned based on roles
- **Combined Permissions**: When a user has multiple roles, permissions are combined from all roles
- **Manual Override**: Permissions can be manually edited for fine-grained control
- **Granular Control**: Fine-grained permissions for every action in the system

**Approval Workflow**: Any output (design or estimation) cannot proceed to the next stage without approval from authorized reviewers (currently Admin, but can be assigned to other roles via permissions).

**Scalability**: Permissions can be reassigned or modified without changing the system structure, allowing flexible workflow adjustments.

### 2. Project Lifecycle (Dual-Track System)

**Design Track**: Hierarchical review system starting from junior engineer, progressing to senior engineer, then to the client.

**Direct Execution Track**: Ability to open a "Execution Only" project and skip the design phase, with support for uploading external client files.

### 3. Real-World Pricing System (Field-Based Pricing)

**Field Pricing**: Based on inputs from the Civil Engineer (site engineer) based on real-world inspection and current market prices. Civil Engineers and Admins can create and manage pricing.

**Price Review**: Estimates go through an "Administrative Review Filter" before contract issuance to ensure profit margins and quantity accuracy. Users with `can_review_pricing` permission can review and approve pricing.

**Quote Generation**: Professional PDF export with company logo from entered data.

### 4. Flexible Financial Management (Smart Accounting)

**Custom Payment Milestones**: Ability to define the number and percentages of payments (3 payments or more) customized for each contract.

**Progress Linking**: "Execution Tasks" for the next phase are not activated until the Accountant confirms receipt of the associated financial payment.

**Accountant Role**: Dedicated role for managing financial operations, payment schedules, and financial reporting. Accountants can view all projects for financial context and manage payment confirmations.

### 5. Task Management & Documentation

**Phase Documentation**: Engineers are required to upload "before and after" photos and technical receipts for each item (plumbing, electrical, etc.).

**Activity Logs (Audit Logs)**: Detailed tracking of every modification to prices or schedules (who modified? what was changed? when?).

### 6. Admin Dashboard & User Management

**Admin Interface**: Comprehensive admin dashboard for system management:
- User management with multiple role assignment
- Permission management (auto-assigned and editable)
- Project oversight and analytics
- System configuration

**Admin Permissions**: Admins automatically receive ALL permissions in the system, including:
- Full project management
- User and role management
- Financial operations
- Technical reviews and approvals
- Pricing creation and management

## 🛠️ Technical Workflow

1. **Lead Capture**: Record client data and service type (design/execution)
2. **Estimation**: Civil Engineer creates pricing based on site inspection and uploads inspection data
3. **Vetting**: Authorized reviewers (users with `can_review_pricing` permission, currently Admin) review the estimate technically and financially
4. **Contracting**: Client approval → Accountant sets up payment schedule
5. **Activation**: Upon first payment confirmation by Accountant, project transitions from "Quotation" to "Active Project"
6. **Operation**: Tasks open for Civil Engineer with progress monitoring and photo documentation
7. **Handover**: Final delivery and project archiving

## 🔐 Role-Based Access Control with Permissions

### System Roles

The system supports the following roles, each with default permissions that are automatically assigned:

#### 1. **Admin**
- **Default Permissions**: ALL permissions in the system (special case)
- **Can Do**: Everything - full system control
- **Use Case**: System administrators who need complete access
- **Note**: Admin role automatically grants all permissions, no need to list them individually

#### 2. **Manager**
- **Default Permissions**:
  - `can_create_projects` - Create new projects
  - `can_edit_projects` - Edit projects
  - `can_view_all_projects` - View all projects
  - `can_approve_pricing` - Approve pricing for contracts
  - `can_view_financial` - View financial data
- **Use Case**: Project managers overseeing operations

#### 3. **Senior Engineer**
- **Default Permissions**:
  - `can_review_pricing` - Review and approve pricing
  - `can_view_all_projects` - View all projects
  - `can_edit_projects` - Edit assigned projects
- **Use Case**: Senior engineers who review and approve junior work

#### 4. **Junior Engineer**
- **Default Permissions**:
  - `can_view_assigned_projects` - View only assigned projects
  - `can_execute_tasks` - Execute tasks on assigned projects
- **Use Case**: Entry-level engineers working on specific projects

#### 5. **Civil Engineer** (Site Engineer)
- **Default Permissions**:
  - `can_create_pricing` - Create pricing/estimations (تسعير)
  - `can_edit_pricing` - Edit pricing
  - `can_view_pricing` - View pricing data
  - `can_track_projects` - Track assigned projects
  - `can_view_assigned_projects` - View assigned projects
  - `can_view_invoice_cost` - View invoice cost prices
  - `can_alert_accountant` - Alert Accountant about invoices that need payment
- **Special Capabilities**:
  - Can see which projects they're assigned to (this week/day view)
  - Can alert Accountants about pending invoices
  - Can view invoice cost prices
- **Use Case**: Engineers who perform site inspections and create cost estimates
- **Note**: "Site Engineer" and "Civil Engineer" refer to the same role

#### 6. **Accountant**
- **Default Permissions**:
  - `can_view_financial` - View financial data
  - `can_manage_payments` - Manage payment schedules
  - `can_approve_payments` - Approve payment confirmations
  - `can_view_all_projects` - View all projects (for financial context)
- **Use Case**: Financial staff managing payments and accounting

### Permission System

#### How It Works

1. **Auto-Assignment**: When a user is assigned a role, they automatically receive the default permissions for that role
2. **Multiple Roles**: Users can have multiple roles, and permissions are combined from all roles
3. **Manual Override**: Admins can manually add or remove permissions for any user
4. **Combined Permissions**: If a user has multiple roles, all permissions from all roles are combined (duplicates are automatically removed)
5. **Effective Permissions**: The system uses "effective permissions" which is the combination of:
   - All permissions from all assigned roles
   - Plus any manually assigned permissions

#### Permission Categories

**Pricing Permissions**:
- `can_create_pricing` - Create pricing/estimations (تسعير)
- `can_edit_pricing` - Edit pricing
- `can_approve_pricing` - Approve pricing for contracts
- `can_review_pricing` - Review pricing (technical/financial review)
- `can_view_pricing` - View pricing data

**Project Permissions**:
- `can_create_projects` - Create new projects
- `can_edit_projects` - Edit projects
- `can_delete_projects` - Delete projects
- `can_view_all_projects` - View all projects in the system
- `can_view_assigned_projects` - View only assigned projects
- `can_track_projects` - Track and monitor assigned projects (with calendar/weekly view)

**Financial Permissions**:
- `can_view_financial` - View financial data
- `can_manage_payments` - Manage payment schedules
- `can_approve_payments` - Approve payment confirmations
- `can_view_invoice_cost` - View invoice cost prices

**Communication Permissions**:
- `can_alert_accountant` - Alert Accountant about pending invoices

**Admin Permissions**:
- `can_manage_users` - Create, edit, delete users
- `can_manage_roles` - Assign roles and permissions
- `can_view_reports` - Access system reports and analytics

**Task Permissions**:
- `can_execute_tasks` - Execute tasks on assigned projects

#### Example Scenarios

**Scenario 1: Civil Engineer**
{
  "roles": ["civil_engineer"],
  "permissions": [],
  "effectivePermissions": [
    "can_create_pricing",
    "can_edit_pricing",
    "can_view_pricing",
    "can_track_projects",
    "can_view_assigned_projects",
    "can_view_invoice_cost",
    "can_alert_accountant"
  ]
}**Scenario 2: User with Multiple Roles (Civil Engineer + Accountant)**
{
  "roles": ["civil_engineer", "accountant"],
  "permissions": [],
  "effectivePermissions": [
    // From civil_engineer role:
    "can_create_pricing",
    "can_edit_pricing",
    "can_view_pricing",
    "can_track_projects",
    "can_view_assigned_projects",
    "can_view_invoice_cost",
    "can_alert_accountant",
    // From accountant role:
    "can_view_financial",
    "can_manage_payments",
    "can_approve_payments",
    "can_view_all_projects"
    // Combined: User has ALL permissions from both roles!
  ]
}**Scenario 3: Manager with Extra Pricing Permission**
{
  "roles": ["manager"],
  "permissions": ["can_create_pricing"],  // Extra permission added manually
  "effectivePermissions": [
    // From manager role:
    "can_create_projects",
    "can_edit_projects",
    "can_view_all_projects",
    "can_approve_pricing",
    "can_view_financial",
    // Manual permission:
    "can_create_pricing"
  ]
}**Scenario 4: Admin (All Permissions)**son
{
  "roles": ["admin"],
  "permissions": [],
  "effectivePermissions": [
    // Admin automatically gets ALL permissions:
    "can_create_pricing",
    "can_edit_pricing",
    "can_approve_pricing",
    "can_review_pricing",
    "can_create_projects",
    "can_edit_projects",
    "can_delete_projects",
    "can_view_all_projects",
    "can_view_financial",
    "can_manage_payments",
    "can_manage_users",
    "can_manage_roles",
    // ... and all other permissions in the system
  ]
}
### Project Access Control

- **Junior Engineer**: Can only view and work on assigned projects
- **Senior Engineer**: Can view all projects and approve work
- **Manager**: Can view all projects, manage assignments, and oversee operations
- **Civil Engineer**: Can view assigned projects, create pricing, track projects, view invoice costs, and alert Accountants
- **Accountant**: Can view all projects (for financial context) and manage payments
- **Admin**: Full access to all projects, users, and system settings

### Civil Engineer Special Features

Civil Engineers have enhanced project tracking capabilities:

1. **Project Calendar View**: Can see which projects they're assigned to for:
   - Today
   - This week
   - This month

2. **Invoice Management**:
   - Can view invoice cost prices for assigned projects
   - Can alert Accountants when invoices need to be paid to proceed with projects
   - Direct communication with Accountant role

3. **Project Tracking**:
   - Real-time project status monitoring
   - Task assignment visibility
   - Progress tracking

## 📈 Future Roadmap

- Client portal for progress tracking and photo viewing
- Automatic notification system (Auto-Reminders) for payment deadlines
- Direct integration with warehouses and suppliers for supply orders
- Advanced analytics and reporting dashboard
- Mobile app for field engineers
- Custom permission templates for common role combinations
- Role-based dashboard customization

## 🏗️ Architecture

- **Frontend**: Flutter (Cross-platform: Web, iOS, Android, Desktop)
- **State Management**: BLoC Pattern
- **Routing**: GoRouter with permission-based guards
- **Architecture**: Clean Architecture with Domain-Driven Design
- **Localization**: English and Arabic support
- **Access Control**: Role-Based Access Control (RBAC) with Permission-Based Access Control (PBAC)
  - Multiple roles per user
  - Auto-assigned permissions from roles
  - Combined permissions from multiple roles
  - Manual permission override capability

## 📝 Note

This system is designed for "ambitious offices" that start with a small team but establish a professional foundation for growth. The role and permission-based access control ensures scalability and security as the organization expands, while allowing flexible role assignments and permission customization. Users can have multiple roles, and permissions are automatically combined, making it easy to handle employees who wear multiple hats in small to medium-sized companies.# 🏗️ Rawnaq - Integrated Construction & Design ERP System

## 📋 Overview

A comprehensive technical and administrative system designed for small and medium-sized construction and finishing companies. Rawnaq bridges the gap between the design department (hierarchical structure) and the execution department, with a flexible project lifecycle that starts from site inspection to key handover.

## 🚀 Core Features

### 1. Flexible Management Hierarchy (Scalable Hierarchy)

**Role-Based Access Control (RBAC)**: Clear separation of permissions between roles:
- **Junior Engineer**: Basic project access, task execution
- **Senior Engineer**: Review and approval capabilities
- **Manager**: Project oversight and team management
- **Admin**: Full system access with configurable sub-roles

**Approval Workflow**: Any output (design or estimation) cannot proceed to the next stage without approval from the "Technical Reviewer".

**Scalability**: Ability to transfer review tasks from "Admin" to "Senior Engineer" in the future with a single click, without changing the system structure.

### 2. Project Lifecycle (Dual-Track System)

**Design Track**: Hierarchical review system starting from junior engineer, progressing to senior engineer, then to the client.

**Direct Execution Track**: Ability to open a "Execution Only" project and skip the design phase, with support for uploading external client files.

### 3. Real-World Pricing System (Field-Based Pricing)

**Field Pricing**: Based on inputs from the site engineer (supervisor) based on real-world inspection and current market prices.

**Price Review**: Estimates go through an "Administrative Review Filter" before contract issuance to ensure profit margins and quantity accuracy.

**Quote Generation**: Professional PDF export with company logo from entered data.

### 4. Flexible Financial Management (Smart Accounting)

**Custom Payment Milestones**: Ability to define the number and percentages of payments (3 payments or more) customized for each contract.

**Progress Linking**: "Execution Tasks" for the next phase are not activated until the accountant confirms receipt of the associated financial payment.

### 5. Task Management & Documentation

**Phase Documentation**: Engineers are required to upload "before and after" photos and technical receipts for each item (plumbing, electrical, etc.).

**Activity Logs (Audit Logs)**: Detailed tracking of every modification to prices or schedules (who modified? what was changed? when?).

### 6. Admin Dashboard & User Management

**Admin Interface**: Comprehensive admin dashboard for system management:
- User management with role assignment
- Project oversight and analytics
- System configuration
- Role and permission management

**Admin Roles**: Admins can have sub-roles for granular permission control:
- System Admin: Full access
- Project Admin: Project management only
- Financial Admin: Financial operations only
- Technical Admin: Technical review and approval

## 🛠️ Technical Workflow

1. **Lead Capture**: Record client data and service type (design/execution)
2. **Estimation**: Site engineer uploads inspection data and prices
3. **Vetting**: Admin reviews the estimate technically and financially
4. **Contracting**: Client approval → payment schedule is determined
5. **Activation**: Upon first payment, project transitions from "Quotation" to "Active Project"
6. **Operation**: Tasks open for site engineer with progress monitoring and photo documentation
7. **Handover**: Final delivery and project archiving

## 🔐 Role-Based Access Control

### Project Access by Role

- **Junior Engineer**: Can view and work on assigned projects only
- **Senior Engineer**: Can view all projects, review and approve junior engineer work
- **Manager**: Can view all projects, manage team assignments, and oversee operations
- **Admin**: Full access to all projects, users, and system settings

### Admin Sub-Roles

Admins can be assigned specific sub-roles for focused access:
- **System Admin**: Complete system control
- **Project Admin**: Manage all projects and assignments
- **Financial Admin**: Access financial data and payment management
- **Technical Admin**: Technical reviews and approvals

## 📈 Future Roadmap

- Client portal for progress tracking and photo viewing
- Automatic notification system (Auto-Reminders) for payment deadlines
- Direct integration with warehouses and suppliers for supply orders
- Advanced analytics and reporting dashboard
- Mobile app for field engineers

## 🎨 Design & User Interface

### App Theme

Rawnaq features a modern dark theme designed for professional project management workflows. The theme is built on Material Design 3 principles with a sophisticated color palette optimized for extended use and reduced eye strain.

**Color Palette**:
- **Primary Color**: Soft lavender-beige (#DFD8DE) - A sophisticated, muted accent color that provides excellent contrast against dark backgrounds while maintaining a professional, elegant appearance
- **Background**: Deep charcoal (#161B22) - The main background color creates a comfortable viewing environment
- **Surface Colors**: Layered dark grays (#1C2128, #21262D) - Provide visual hierarchy and depth
- **Text Colors**: High-contrast whites and grays for optimal readability
  - Primary text: Pure white for maximum clarity
  - Secondary text: Medium gray (#8B949E) for supporting information
  - Muted text: Lighter gray (#6E7681) for less important details

**Status Colors**:
- Active/Info: Bright blue (#3B82F6)
- Success: Fresh green (#22C55E)
- Warning: Amber (#F59E0B)
- Error: Red (#EF4444)

**Design Philosophy**:
The dark theme reduces eye fatigue during long work sessions while maintaining excellent readability. The soft lavender-beige primary color adds a distinctive brand identity without being overwhelming. All UI components follow consistent styling with rounded corners, subtle borders, and smooth transitions for a polished, modern appearance.

### Layout & Navigation

Rawnaq employs a responsive layout system that adapts seamlessly to different screen sizes, providing an optimal experience whether accessed on desktop, tablet, or mobile devices.

**Desktop Layout (Screens 768px and wider)**:
The desktop experience features a split-screen layout with the main content area on the left and a persistent sidebar navigation on the right side. This design accommodates right-to-left (RTL) language support for Arabic users. The sidebar is fixed at 260 pixels wide and contains three distinct sections:

1. **Header Section**: At the top of the sidebar, displays the company logo (represented by a business icon in a rounded container) alongside the company name and a subtitle indicating "Project Management". This header is separated from the navigation by a subtle divider.

2. **Main Navigation Section**: The central, scrollable area contains the primary navigation items. Each navigation item displays an icon, label text, and visual feedback for the active state. Active items are highlighted with a subtle background tint, a border accent, and a small circular indicator dot. Navigation items include Dashboard, Projects, Gantt Chart, Tasks, and Reports.

3. **Bottom Section**: Separated by a divider, the bottom area contains secondary navigation items such as Settings and Help. This separation creates a clear visual hierarchy between primary and secondary actions.

The main content area expands to fill the remaining screen space, allowing pages to utilize the full width for data tables, charts, and detailed project information.

**Mobile Layout (Screens smaller than 768px)**:
On mobile devices, the sidebar is replaced with a bottom navigation bar that remains fixed at the bottom of the screen. This approach maximizes screen real estate for content while keeping navigation easily accessible with thumb-friendly tap targets. The bottom navigation bar uses the same color scheme as the desktop sidebar and displays icons with labels for each main section.

**Navigation Features**:
- **Active State Indication**: The current page is clearly indicated through multiple visual cues including icon changes (outlined to filled), color highlighting, background tinting, and indicator dots
- **Smooth Transitions**: Page navigation uses fade transitions for a polished, professional feel
- **Responsive Breakpoint**: The layout automatically switches between desktop and mobile modes at the 768-pixel breakpoint
- **RTL Support**: The layout is designed to work seamlessly with both left-to-right and right-to-left text directions

**Content Structure**:
Pages within the main content area follow consistent padding and spacing guidelines. Cards, tables, and data visualizations are presented with subtle borders, rounded corners, and appropriate shadows to create depth and visual separation. The overall design emphasizes clarity, hierarchy, and ease of use for managing complex project information.

## 🏗️ Architecture

- **Frontend**: Flutter (Cross-platform: Web, iOS, Android, Desktop)
- **State Management**: BLoC Pattern
- **Routing**: GoRouter with role-based guards
- **Architecture**: Clean Architecture with Domain-Driven Design
- **Localization**: English and Arabic support

## 📝 Note

This system is designed for "ambitious offices" that start with a small team but establish a professional foundation for growth. The role-based access control ensures scalability and security as the organization expands.

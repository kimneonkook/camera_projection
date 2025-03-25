%Reads the 3D object
TR=stlread("man_small.stl");
vertices = TR.Points; % Extract the vertices (coordinates) of the 3D model
faces = TR.ConnectivityList; % Extract the connectivity list (faces) of the 3D model
trimesh(TR);

%Visualizing the 3D Model with customized lighting and material
figure;
patch('Faces',faces,'Vertices',vertices,'FaceColor',[0.4660 0.6740 0.1880],'EdgeColor','none','FaceLight','gouraud','AmbientStrength',0.15); % Plot the 3D object with face colors and lighting
camlight('headlight');  % Add a light source to the camera's position
material('dull'); %matte finish
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
rotate3d on;

%Distance to shift along the Y-axis between stacked humans
shiftY=0.5;
Vertices=[];  % Initialize an empty array to store all vertices
Faces=[]; % Initialize an empty array to store all faces

% Loop to create multiple humans by shifting their Y positions
for i=0:4
    newVertices=vertices+[0,i*shiftY,0]; % Shift vertices along Y-axis by 'i' * shiftY
    Vertices=[Vertices;newVertices];

    newFaces=faces + i*size(vertices,1); % Adjust faces indices for each duplicate human
    Faces=[Faces;newFaces];
end


% Display the stacked 3D humans
figure;
patch('Faces', Faces, 'Vertices', Vertices,'FaceColor', [0.4660 0.6740 0.1880],'EdgeColor', 'none', 'FaceLight', 'gouraud','AmbientStrength', 0.15);
camlight('headlight');
material('dull');
axis equal; 
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
rotate3d on;

%Camera Transformation Matrices
Ry=[0 0 -1; 0 1 0; 1 0 0]; % Rotation matrix around Y-axis
Rx=[1 0 0; 0 0 -1; 0 1 0]; % Rotation matrix around X-axis
R=Ry*Rx; % Combine the two rotations into one matrix (resulting in a full transformation)
t_cam=[-2;0.8;0];  % Define the camera position (translation vector)
t=-R*t_cam; % Calculate the camera translation in the world coordinates 
Pextr=[R t;0 0 0 1]; % Create the full camera extrinsic matrix (rotation + translation)


% Create a homogeneous matrix for the vertices (adding the extra row of ones)
Q=[Vertices'; ones(1,size(Vertices,1))];
disp(Q);
Q1=Pextr*Q;
disp(Q1);
Qfinal=(Q1(1:3,:) ./ Q1(3,:))'; % Normalize the coordinates by dividing by the third (homogeneous) coordinate

% Extract 2D coordinates from the 3D projection
u = Qfinal(:,1); % Extract the u (x-coordinate) values
v = Qfinal(:,2); % Extract the v (y-coordinate) values


% Save the 2D coordinates into a matrix and display them
finalMatrix = [Qfinal(1, :); Qfinal(2, :)];
ID = (1:size(finalMatrix, 2))';  % Create an ID for each point
disp(finalMatrix);


% Plot the 2D projection
figure;
plot(u, v, 'k.', 'MarkerSize', 5);  % Plot the 2D coordinates as black dots
hold on;
grid on;
xlabel('u (image)');
ylabel('v (image)');
axis equal;
set(gca, 'YDir', 'reverse'); % Reverse the Y-axis (to match image coordinate systems)
xlim([min(u)-0.1, max(u)+0.1]); % Set limits for the X-axis with a small buffer
ylim([min(v)-0.1, max(v)+0.1]); % Set limits for the Y-axis with a small buffer

rotate3d on;
title('Camera Projection');

% Save the 2D projection coordinates to an Excel file
writematrix(finalMatrix', 'TransformedCoordinates.xlsx');  % Αποθήκευση σε Excel


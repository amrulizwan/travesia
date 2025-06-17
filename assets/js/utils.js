<div class="container">
  <header class="d-flex justify-content-between align-items-center">
    <h1>Travesia Admin Dashboard</h1>
    <button class="btn btn-primary" id="addPengelolaBtn">Add Pengelola</button>
  </header>
  
  <div class="row mt-4">
    <div class="col-md-4">
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">Total Users</h5>
          <p class="card-text" id="totalUsers">0</p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">Active Pengelola</h5>
          <p class="card-text" id="activePengelola">0</p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">Recent Activities</h5>
          <ul id="recentActivities">
            <!-- Recent activities will be populated here -->
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>